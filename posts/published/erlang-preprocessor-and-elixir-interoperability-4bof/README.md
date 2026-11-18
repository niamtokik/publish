---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/erlang-preprocessor-and-elixir-interoperability-4bof"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fhr71tmdeto91mpeee388.jpg"
created_at: "None"
crossposted_at: "None"
description: "Erlang and Elixir are both running on the BEAM, the Erlang Virtual Machine, designed for long-living..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/erlang-preprocessor-and-elixir-interoperability-4bof"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "erlang-preprocessor-and-elixir-interoperability-4bof"
social_image: "None"
title: "Erlang Preprocessor and Elixir Interoperability"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Erlang Preprocessor and Elixir Interoperability

Erlang and Elixir are both running on the BEAM, the Erlang Virtual Machine, designed for long-living and distribute. In most of the case, talking to Erlang modules via Elixir is straightforward, doing the opposite can be a bit challenging though, but it is okay. In few cases though, extracting values from Erlang can become a real problem. The Erlang PreProcessor (`epp`) is used to expand Erlang macros before compiling the code, this is a similar feature than one can found in `C`, `C++` and many other languages. This is a powerful way to avoid code-deduplication, and optimize the execution of the code by directly applying a data-structure instead of a reference. It has many other benefits, but this is not the place here to list them all.

# Erlang From Code Source to AST

Before doing anything, one should understand a bit how Erlang and the BEAM are working together. The procedure to compile Erlang source code into a binary file is a complex process, but it is possible to have the big picture in few steps.

Firstly, one need to create a file containing Erlang source code. In fact, this is not mandatory to create a file... but we will see that later. As reminder, an Erlang file prefix is `.erl`, and the name of the file must match the name of the module defined in the module itself..

```console
$ cat > mod.erl <<EOF
-module(mod).
-compile(export_all).
-define(DATA, <<1,2,3,4,5>>).

f() -> ?DATA.
EOF
```

The code created is straightforward. A simple module is created exporting all functions, a macro is defined containing a binary, and finally, a function called `f/0` is defined, returning the content of the macro.

The second step is to call the Erlang preprocessor called [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) to expand all [macros](https://erlang.org/documentation/doc-4.8.2/doc/extensions/macros.html) and generate the final source code. The preprocessor will import functions or data-structures from the external libraries (`-include` and `-include_lib`), expands the macros (`-define` and `?MACRO`) and can return a list of tokens or the fully expanded source code. This part can easily be seen by using the `-P` or `-E` flags with the command [`erlc`](https://www.erlang.org/doc/apps/erts/erlc_cmd.html).

```console
$ erlc -P mod.erl

$ cat mod.P
-file("mod.erl", 1).
-module(mod).
-compile(export_all).

f() ->
    <<1,2,3,4,5>>
```

As you can see, the file `mod.P` does not have any `-define` attribute, and the macro has been expanded. A new attribute `-file` has also been added to the source, at the first line. The preprocessor did its job, and the source code can now be tokenized.

The tokenization procedure can't be seen via a command line, and it will be required to evaluate an Erlang one-line with the [`erl`](https://www.erlang.org/doc/apps/erts/erl_cmd.html) command to have an idea of what's happening.

```console
$ erl -noshell -eval '
  {ok, M}=file:read_file("mod.P"), 
  T = erl_scan:string(binary_to_list(M)),
  io:format("~p~n", [T]),
  init:stop().
'
{ok,[{'-',1},
     {atom,1,file},
     {'(',1},
     {string,1,"mod.erl"},
     {',',1},
     {integer,1,1},
     {')',1},
     {dot,1},
     {'-',3},
     {atom,3,module},
     {'(',3},
     {atom,3,mod},
     {')',3},
     {dot,3},
     {'-',5},
     {atom,5,compile},
     {'(',5},
     {atom,5,export_all},
     {')',5},
     {dot,5},
     {atom,7,f},
     {'(',7},
     {')',7},
     {'->',7},
     {'<<',8},
     {integer,8,1},
     {',',8},
     {integer,8,2},
     {',',8},
     {integer,8,3},
     {',',8},
     {integer,8,4},
     {',',8},
     {integer,8,5},
     {'>>',8},
     {dot,8}],
    12}
```

Here, the `mod.P` has been used instead of `mod.erl`, because usually, the scanner is scanning the expanded file, not the one containing the macros. This snippet is reading the source code, calling [`erl_scan:string/1`](https://www.erlang.org/doc/apps/stdlib/erl_scan.html#string/3) to scan the tokens, [`io:format/2`](https://www.erlang.org/doc/apps/stdlib/io.html#t:format/0) is called to print the result and finally, the VM is stopped by invoking [`init:stop/0`](https://www.erlang.org/doc/apps/erts/init.html#stop/0). The result displayed is a list of tokens containing the annotations for each characters.

A quick note here, [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) is usually privileged than [`erl_scan`](https://www.erlang.org/doc/apps/stdlib/erl_scan.html). The tokens from [`epp:parse_file/2`](https://www.erlang.org/doc/apps/stdlib/epp.html#parse_file/2) are already ready to be used with the parser. Here and example:

```console
$ erl -noshell -eval '
  {ok, T} = epp:parse_file("./mod.erl", [{source_name, mod}]),
  io:format("~p~n", [T]),
  init:stop().
'
[{attribute,1,file,{"mod",1}},
 {attribute,1,module,mod},
 {attribute,2,compile,export_all},
 {function,5,f,0,
           [{clause,5,[],[],
                    [{bin,5,
                          [{bin_element,5,{integer,5,1},default,default},
                           {bin_element,5,{integer,5,2},default,default},
                           {bin_element,5,{integer,5,3},default,default},
                           {bin_element,5,{integer,5,4},default,default},
                           {bin_element,5,{integer,5,5},default,default}]}]}]},
 {eof,6}]
```

Let continue on the previous procedure. The next step before generating the AST (Abstract Syntax Tree) above, is to parse the tokens produced by [`erl_scan`](https://www.erlang.org/doc/apps/stdlib/erl_scan.html). To do that, [`erl_parse`](https://www.erlang.org/doc/apps/stdlib/erl_parse.html) module is used. The final result can be produced with the `-S` flag when calling [`erlc`](https://www.erlang.org/doc/apps/erts/erlc_cmd.html) or by calling [`erl_parse`](https://www.erlang.org/doc/apps/stdlib/erl_parse.html) directly from the shell. Below, the AST produced by [`erlc`](https://www.erlang.org/doc/apps/erts/erlc_cmd.html).

```console
$ erlc -S mod.erl

$ cat mod.S
{module, mod}.  %% version = 0
{exports, [{f,0},{module_info,0},{module_info,1}]}.
{attributes, []}.
{labels, 7}.
{function, f, 0, 2}.
  {label,1}.
    {line,[{location,"mod.erl",5}]}.
    {func_info,{atom,mod},{atom,f},0}.
  {label,2}.
    {move,{literal,<<1,2,3,4,5>>},{x,0}}.
    return.
{function, module_info, 0, 4}.
  {label,3}.
    {line,[]}.
    {func_info,{atom,mod},{atom,module_info},0}.
  {label,4}.
    {move,{atom,mod},{x,0}}.
    {call_ext_only,1,{extfunc,erlang,get_module_info,1}}.
{function, module_info, 1, 6}.
  {label,5}.
    {line,[]}.
    {func_info,{atom,mod},{atom,module_info},1}.
  {label,6}.
    {move,{x,0},{x,1}}.
    {move,{atom,mod},{x,0}}.
    {call_ext_only,2,{extfunc,erlang,get_module_info,2}}
```

The very same result can be done using [`erl_parse:parse_form/1`](https://www.erlang.org/doc/apps/stdlib/erl_parse.html#parse_form/1), [`erl_parse:parse_exprs/1`](https://www.erlang.org/doc/apps/stdlib/erl_parse.html#parse_exprs/1) or [`erl_parse_term/1`](https://www.erlang.org/doc/apps/stdlib/erl_parse.html#parse_term/1) when the tokens are grouped using the `{dot,_}` token.

```console
> erl_parse:parse_form([
  {'-',1},{atom,1,file},{'(',1},
    {string,1,"mod.erl"},{',',1},
  {integer,1,1},{')',1},{dot,1}
]).
{ok,{attribute,1,file,{"mod.erl",1}}}

> erl_parse:parse_form([
  {atom,7,f}, {'(',7}, {')',7}, {'->',7},
     {'<<',8},
       {integer,8,1}, {',',8},
       {integer,8,2}, {',',8},
       {integer,8,3}, {',',8},
       {integer,8,4}, {',',8},
       {integer,8,5},
     {'>>',8},
     {dot,8}
]).
{ok,{function,7,f,0,
              [{clause,7,[],[],
                       [{bin,8,
                             [{bin_element,8,{integer,8,1},default,default},
                              {bin_element,8,{integer,8,2},default,default},
                              {bin_element,8,{integer,8,3},default,default},
                              {bin_element,8,{integer,8,4},default,default},
                              {bin_element,8,{integer,8,5},default,default}]}]}]}}

> erl_parse:parse_term([
  {'<<',8},
    {integer,8,1}, {',',8},
    {integer,8,2}, {',',8},
    {integer,8,3}, {',',8},
    {integer,8,4}, {',',8},
    {integer,8,5},
  {'>>',8},
  {dot,8}
]).
{ok,<<1,2,3,4,5>>}

> {ok, File} = file:read_file("mod.P"), 
  {ok, Tokens, _} = erl_scan:string(
    binary_to_list(File)
  ),
  {_, AST} = lists:foldl(fun
      (D = {dot, _}, {Buf, Acc}) ->
        {ok, R} = erl_parse:parse_form(
          lists:reverse([D|Buf])
        ),
        {[], [R|Acc]};
      (T, {Buf,Acc}) ->
        {[T|Buf], Acc}
    end,
    {[], []},
    Tokens
  ),
  lists:reverse(AST).
[{attribute,1,file,{"mod.erl",1}},
 {attribute,3,module,mod},
 {attribute,5,compile,export_all},
 {function,7,f,0,
           [{clause,7,[],[],
                    [{bin,8,
                          [{bin_element,8,{integer,8,1},default,default},
                           {bin_element,8,{integer,8,2},default,default},
                           {bin_element,8,{integer,8,3},default,default},
                           {bin_element,8,{integer,8,4},default,default},
                           {bin_element,8,{integer,8,...},default,default}]}]}]}]
```

More steps are executed after generating the AST, a linter and other checkers can verify the code, but it will be discarded in this part of the article. To finally generate the Erlang bytecode, the file with `.beam` prefix, containing the compiled source code, one can call [`erlc`](https://www.erlang.org/doc/apps/erts/erlc_cmd.html) again or use the [`compile:file/2`](https://www.erlang.org/doc/apps/compiler/compile.html#file/1) function when a file is available.

```console
$ erlc mod.erl

$ file mod.beam                                                                                                                                                                                                                                                                 
mod.beam: Erlang BEAM file

$ hexdump -C mod.beam        
00000000  46 4f 52 31 00 00 02 50  42 45 41 4d 41 74 55 38  |FOR1...PBEAMAtU8|
00000010  00 00 00 2d ff ff ff fb  30 6d 6f 64 10 66 b0 6d  |...-....0mod.f.m|
00000020  6f 64 75 6c 65 5f 69 6e  66 6f 60 65 72 6c 61 6e  |odule_info`erlan|
00000030  67 f0 67 65 74 5f 6d 6f  64 75 6c 65 5f 69 6e 66  |g.get_module_inf|
00000040  6f 00 00 00 43 6f 64 65  00 00 00 47 00 00 00 10  |o...Code...G....|
00000050  00 00 00 00 00 00 00 b1  00 00 00 07 00 00 00 03  |................|
00000060  01 10 99 10 02 12 22 00  01 20 40 47 00 03 13 01  |......".. @G....|
00000070  30 99 00 02 12 32 00 01  40 40 12 03 4e 10 00 01  |0....2..@@..N...|
00000080  50 99 00 02 12 32 10 01  60 40 03 13 40 12 03 4e  |P....2..`@..@..N|
00000090  20 10 03 00 53 74 72 54  00 00 00 00 49 6d 70 54  | ...StrT....ImpT|
000000a0  00 00 00 1c 00 00 00 02  00 00 00 04 00 00 00 05  |................|
000000b0  00 00 00 01 00 00 00 04  00 00 00 05 00 00 00 02  |................|
000000c0  45 78 70 54 00 00 00 28  00 00 00 03 00 00 00 03  |ExpT...(........|
000000d0  00 00 00 01 00 00 00 06  00 00 00 03 00 00 00 00  |................|
000000e0  00 00 00 04 00 00 00 02  00 00 00 00 00 00 00 02  |................|
000000f0  4c 69 74 54 00 00 00 17  00 00 00 00 00 00 00 01  |LitT............|
00000100  00 00 00 0b 83 6d 00 00  00 05 01 02 03 04 05 00  |.....m..........|
00000110  4d 65 74 61 00 00 00 2d  83 6c 00 00 00 01 68 02  |Meta...-.l....h.|
00000120  77 10 65 6e 61 62 6c 65  64 5f 66 65 61 74 75 72  |w.enabled_featur|
00000130  65 73 6c 00 00 00 01 77  0a 6d 61 79 62 65 5f 65  |esl....w.maybe_e|
00000140  78 70 72 6a 6a 00 00 00  4c 6f 63 54 00 00 00 04  |xprjj...LocT....|
00000150  00 00 00 00 41 74 74 72  00 00 00 27 83 6c 00 00  |....Attr...'.l..|
00000160  00 01 68 02 77 03 76 73  6e 6c 00 00 00 01 6e 10  |..h.w.vsnl....n.|
00000170  00 00 4a 2a a7 c3 41 6d  91 07 cf f0 1d 6d 6e 00  |..J*..Am.....mn.|
00000180  85 6a 6a 00 43 49 6e 66  00 00 00 48 83 6c 00 00  |.jj.CInf...H.l..|
00000190  00 03 68 02 77 07 76 65  72 73 69 6f 6e 6b 00 07  |..h.w.versionk..|
000001a0  39 2e 30 2e 36 2e 31 68  02 77 07 6f 70 74 69 6f  |9.0.6.1h.w.optio|
000001b0  6e 73 6a 68 02 77 06 73  6f 75 72 63 65 6b 00 13  |nsjh.w.sourcek..|
000001c0  2f 74 6d 70 2f 65 72 6c  61 6e 67 2f 6d 6f 64 2e  |/tmp/erlang/mod.|
000001d0  65 72 6c 6a 44 62 67 69  00 00 00 48 83 68 03 77  |erljDbgi...H.h.w|
000001e0  0d 64 65 62 75 67 5f 69  6e 66 6f 5f 76 31 77 11  |.debug_info_v1w.|
000001f0  65 72 6c 5f 61 62 73 74  72 61 63 74 5f 63 6f 64  |erl_abstract_cod|
00000200  65 68 02 77 04 6e 6f 6e  65 6c 00 00 00 01 68 02  |eh.w.nonel....h.|
00000210  77 03 63 77 64 6b 00 0b  2f 74 6d 70 2f 65 72 6c  |w.cwdk../tmp/erl|
00000220  61 6e 67 6a 4c 69 6e 65  00 00 00 15 00 00 00 00  |angjLine........|
00000230  00 00 00 00 00 00 00 03  00 00 00 01 00 00 00 00  |................|
00000240  51 00 00 00 54 79 70 65  00 00 00 0a 00 00 00 03  |Q...Type........|
00000250  00 00 00 01 0f ff 00 00                           |........|
00000258
```

If you have only the AST instead of a file containing the source code, the [`compile:forms/2`](https://www.erlang.org/doc/apps/compiler/compile.html#t:forms/0) function can be invoked. It will return the name of the module as `atom()` and the bytecode.

```erlang
> {ok, AST} = epp:parse_file("./mod.erl", [{source_name, mod}]).
{ok,[{attribute,1,file,{"mod",1}},
     {attribute,1,module,mod},
     {attribute,2,compile,export_all},
     {function,5,f,0,
               [{clause,5,[],[],
                        [{bin,5,
                              [{bin_element,5,{integer,5,1},default,default},
                               {bin_element,5,{integer,5,2},default,default},
                               {bin_element,5,{integer,5,...},default,default},
                               {bin_element,5,{integer,...},default,...},
                               {bin_element,5,{...},...}]}]}]},
     {eof,6}]}

> {ok, _Name, Bytecode} = compile:forms(AST, []).
{ok,mod,
    <<70,79,82,49,0,0,1,228,66,69,65,77,65,116,85,56,0,0,0,
      45,255,255,255,251,48,109,...>>}

> file:write_file("/tmp/mod.beam", Bytecode).
ok
```

To be sure the bytecode is working, let open another shell and load it.

```console
$ cd /tmp

$ file mod.beam
mod.beam: Erlang BEAM file

$ hexdump -C mod.beam
00000000  46 4f 52 31 00 00 01 e4  42 45 41 4d 41 74 55 38  |FOR1....BEAMAtU8|
00000010  00 00 00 2d ff ff ff fb  30 6d 6f 64 10 66 b0 6d  |...-....0mod.f.m|
00000020  6f 64 75 6c 65 5f 69 6e  66 6f 60 65 72 6c 61 6e  |odule_info`erlan|
00000030  67 f0 67 65 74 5f 6d 6f  64 75 6c 65 5f 69 6e 66  |g.get_module_inf|
00000040  6f 00 00 00 43 6f 64 65  00 00 00 47 00 00 00 10  |o...Code...G....|
00000050  00 00 00 00 00 00 00 b1  00 00 00 07 00 00 00 03  |................|
00000060  01 10 99 10 02 12 22 00  01 20 40 47 00 03 13 01  |......".. @G....|
00000070  30 99 00 02 12 32 00 01  40 40 12 03 4e 10 00 01  |0....2..@@..N...|
00000080  50 99 00 02 12 32 10 01  60 40 03 13 40 12 03 4e  |P....2..`@..@..N|
00000090  20 10 03 00 53 74 72 54  00 00 00 00 49 6d 70 54  | ...StrT....ImpT|
000000a0  00 00 00 1c 00 00 00 02  00 00 00 04 00 00 00 05  |................|
000000b0  00 00 00 01 00 00 00 04  00 00 00 05 00 00 00 02  |................|
000000c0  45 78 70 54 00 00 00 28  00 00 00 03 00 00 00 03  |ExpT...(........|
000000d0  00 00 00 01 00 00 00 06  00 00 00 03 00 00 00 00  |................|
000000e0  00 00 00 04 00 00 00 02  00 00 00 00 00 00 00 02  |................|
000000f0  4c 69 74 54 00 00 00 17  00 00 00 00 00 00 00 01  |LitT............|
00000100  00 00 00 0b 83 6d 00 00  00 05 01 02 03 04 05 00  |.....m..........|
00000110  4c 6f 63 54 00 00 00 04  00 00 00 00 41 74 74 72  |LocT........Attr|
00000120  00 00 00 27 83 6c 00 00  00 01 68 02 77 03 76 73  |...'.l....h.w.vs|
00000130  6e 6c 00 00 00 01 6e 10  00 f2 e4 49 4c e5 8b 35  |nl....n....IL..5|
00000140  3f a4 aa a7 4e af 2c 9c  e1 6a 6a 00 43 49 6e 66  |?...N.,..jj.CInf|
00000150  00 00 00 28 83 6c 00 00  00 02 68 02 77 07 76 65  |...(.l....h.w.ve|
00000160  72 73 69 6f 6e 6b 00 07  39 2e 30 2e 36 2e 31 68  |rsionk..9.0.6.1h|
00000170  02 77 07 6f 70 74 69 6f  6e 73 6a 6a 44 62 67 69  |.w.optionsjjDbgi|
00000180  00 00 00 2e 83 68 03 77  0d 64 65 62 75 67 5f 69  |.....h.w.debug_i|
00000190  6e 66 6f 5f 76 31 77 11  65 72 6c 5f 61 62 73 74  |nfo_v1w.erl_abst|
000001a0  72 61 63 74 5f 63 6f 64  65 68 02 77 04 6e 6f 6e  |ract_codeh.w.non|
000001b0  65 6a 00 00 4c 69 6e 65  00 00 00 1b 00 00 00 00  |ej..Line........|
000001c0  00 00 00 00 00 00 00 03  00 00 00 01 00 00 00 01  |................|
000001d0  12 51 00 03 6d 6f 64 00  54 79 70 65 00 00 00 0a  |.Q..mod.Type....|
000001e0  00 00 00 03 00 00 00 01  0f ff 00 00              |............|
000001ec

$ erl -noshell -eval '
  io:format("~p~n", [mod:f()]),
  init:stop().
'
<<1,2,3,4,5>>
```

This is only the tip of the iceberg, the compilation process in Erlang is way more complex than that. In fact, many parts of the pipeline have been discarded. Anyway, the goal of this section was simply to show you how to generate quickly Erlang bytecode. The only interesting step for the goal of the post is the preprocessing one. The idea is to extract Erlang records and macros from Erlang source code and convert them into something usable in Elixir.

A last note regarding the compilation process. As you probably know, Elixir templating system using macros is really powerful and the abstraction has been really well designed. Did you know Erlang got the same feature years ago? Indeed, it is also possible to compile dynamically the code or alter the AST directly from the virtual machine via [`merl`](https://www.erlang.org/doc/apps/syntax_tools/merl.html) (for Metaprogramming in Erlang). It's way more complex to use than Elixir templates, but it works pretty well.

BONUS: it is also possible to disassemble the bytecode generated by this process using the [`beam_lib:all_chunks/1`](https://www.erlang.org/doc/apps/stdlib/beam_lib.html#chunks/3) function. It will then give you a better view of the content of a beam file.

```console
$ erl -noshell -eval '
  {ok, F} = file:read_file("./mod.beam"),
  {ok,_,Bytes} = beam_lib:all_chunks(F),
  io:format("~p~n", [Bytes]),
  init:stop().
'
[{"AtU8",
  <<255,255,255,251,48,109,111,100,16,102,176,109,111,100,117,108,101,95,105,
    110,102,111,96,101,114,108,97,110,103,240,103,101,116,95,109,111,100,117,
    108,101,95,105,110,102,111>>},
 {"Code",
  <<0,0,0,16,0,0,0,0,0,0,0,177,0,0,0,7,0,0,0,3,1,16,153,16,2,18,34,0,1,32,64,
    71,0,3,19,1,48,153,0,2,18,50,0,1,64,64,18,3,78,16,0,1,80,153,0,2,18,50,16,
    1,96,64,3,19,64,18,3,78,32,16,3>>},
 {"StrT",<<>>},
 {"ImpT",<<0,0,0,2,0,0,0,4,0,0,0,5,0,0,0,1,0,0,0,4,0,0,0,5,0,0,0,2>>},
 {"ExpT",
  <<0,0,0,3,0,0,0,3,0,0,0,1,0,0,0,6,0,0,0,3,0,0,0,0,0,0,0,4,0,0,0,2,0,0,0,0,0,
    0,0,2>>},
 {"LitT",<<0,0,0,0,0,0,0,1,0,0,0,11,131,109,0,0,0,5,1,2,3,4,5>>},
 {"Meta",
  <<131,108,0,0,0,1,104,2,119,16,101,110,97,98,108,101,100,95,102,101,97,116,
    117,114,101,115,108,0,0,0,1,119,10,109,97,121,98,101,95,101,120,112,114,
    106,106>>},
 {"LocT",<<0,0,0,0>>},
 {"Attr",
  <<131,108,0,0,0,1,104,2,119,3,118,115,110,108,0,0,0,1,110,16,0,0,74,42,167,
    195,65,109,145,7,207,240,29,109,110,0,133,106,106>>},
 {"CInf",
  <<131,108,0,0,0,3,104,2,119,7,118,101,114,115,105,111,110,107,0,7,57,46,48,
    46,54,46,49,104,2,119,7,111,112,116,105,111,110,115,106,104,2,119,6,115,
    111,117,114,99,101,107,0,19,47,116,109,112,47,101,114,108,97,110,103,47,
    109,111,100,46,101,114,108,106>>},
 {"Dbgi",
  <<131,104,3,119,13,100,101,98,117,103,95,105,110,102,111,95,118,49,119,17,
    101,114,108,95,97,98,115,116,114,97,99,116,95,99,111,100,101,104,2,119,4,
    110,111,110,101,108,0,0,0,1,104,2,119,3,99,119,100,107,0,11,47,116,109,
    112,47,101,114,108,97,110,103,106>>},
 {"Line",<<0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,1,0,0,0,0,81>>},
 {"Type",<<0,0,0,3,0,0,0,1,15,255>>}]
```

If you are even more curious about this bonus, you are invited to read [The Beam Book](https://github.com/happi/theBeamBook), you will find there way more information!

# Erlang Preprocessor (`epp`)

The [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) module is in charge to parse and expand macros from Erlang source code. Its source code implementation resides in [`lib/stdlib/epp.erl`](https://github.com/erlang/otp/blob/master/lib/stdlib/src/epp.erl). The content can be intimidating with its 2600 lines of code, but it is not the most complex to read.

`epp` is starting its own server process handling I/O protocols to read data byte by byte with the help of the [`io:scan_erl_form/3`](https://www.erlang.org/doc/apps/stdlib/io.html#scan_erl_form/3). This server is having its own state updated every time a new correct value is parsed. Let begins our investigation by using the easiest function available to parse and expands macros, [`epp:parse_file/2`](https://www.erlang.org/doc/apps/stdlib/epp.html#parse_file/2). Ah, before doing that, let improve a bit our test module.

```console
$ cat > mod2.erl << EOF
-module(mod2).
-compile(export_all).
-record(test, {field1}).
-define(DATA, <<1,2,3,4,5>>).

f() -> ?DATA
EOF
```

An Erlang record called `test` has been added. It was missing from the previous module.

```console
> {ok, AST} = epp:parse_file("mod2.erl", []).
{ok,[{attribute,1,file,{"mod2.erl",1}},
     {attribute,1,module,mod2},
     {attribute,2,compile,export_all},
     {attribute,3,record,
                {test,[{record_field,3,{atom,3,field1}}]}},
     {function,6,f,0,
               [{clause,6,[],[],
                        [{bin,6,
                              [{bin_element,6,{integer,6,1},default,default},
                               {bin_element,6,{integer,6,...},default,default},
                               {bin_element,6,{integer,...},default,...},
                               {bin_element,6,{...},...},
                               {bin_element,6,...}]}]}]},
     {eof,7}]}
```

As you can see, a new attribute for the record is present, containing its description but there is no trace of the `DATA` macro defined (again). This is because `epp` returns the fully expand source code. Great, but those macros should be stored somewhere... right? Indeed, they are stored inside the [`#epp{}` record](https://github.com/erlang/otp/blob/master/lib/stdlib/src/epp.erl#L276) present in the epp server's state. Unfortunately, this server is not directly available when using [`epp:parse_file/2`](https://www.erlang.org/doc/apps/stdlib/epp.html#parse_file/2), and [`epp:open/1`](https://www.erlang.org/doc/apps/stdlib/epp.html#open/1) must be used instead. This function is opening a file using I/O protocols and returns a process identifier to extract all tokens step by steps.

```console
> {ok, EppProcess} = epp:open("mod2.erl", [], []).
{ok,<0.175.0>}
```

To avoid repetitive task, let create `EppRead/2` lambda function to incrementally read the tokens from the epp server. Every time [`epp:scan_erl_form/1`](https://www.erlang.org/doc/apps/stdlib/epp.html#scan_erl_form/1) is called, the epp server should send a message containing its position in the file. When it reaches the end of the file, it sends `{eof, Line}`.

```console
> EppRead = fun EppRead(Pid, Buffer) ->
  case epp:scan_erl_form(Pid) of
    {ok, T} -> EppRead(Pid, Buffer ++ T);
    {eof, _} -> {ok, Buffer}
  end
end.
#Fun<erl_eval.18.113135111>

> {ok, Forms} = EppRead(EppProcess, []).
[{'-',1},
 {atom,1,file},
 {'(',1},
 {string,1,"mod.erl"},
 {',',1},
 {integer,1,1},
 {')',1},
 {dot,1},
 {'-',1},
 {atom,1,module},
 {'(',1},
 {atom,1,mod},
 {')',1},
 {dot,1},
 {'-',2},
 {atom,2,compile},
 {'(',2},
 {atom,2,export_all},
 {')',2},
 {dot,2},
 {atom,5,f},
 {'(',5},
 {')',5},
 {'->',5},
 {'<<',5},
 {integer,5,1},
 {',',5},
 {integer,...},
 {...}|...]
```

Great, the tokens are available, it means it works correctly without any syntax errors. How to extract the process state? The [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) server does not support `sys` patterns, and using [`sys:get_state/1`](https://www.erlang.org/doc/apps/stdlib/sys.html#get_state/1) will simply froze the current process. If you read the source code of the module, you will find the undocumented [`macro_defs/1`](https://github.com/erlang/otp/blob/master/lib/stdlib/src/epp.erl#L456) function. It sends a message to an [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) server and should return the list of macros stored in [server's state](https://github.com/erlang/otp/blob/master/lib/stdlib/src/epp.erl#L1172). Let reimplement this function ourselves.

```console
> GetMacros = fun (Pid) ->
  Pid ! {epp_request, self(), macro_defs},
  receive
    {epp_reply, Pid, Macros} -> Macros
  after
    1000 -> error
  end
end.
#Fun<erl_eval.42.113135111>

> GetMacros(EppProcess).
[{{atom,'FEATURE_ENABLED'},[{1,{['X'],[{atom,1,false}]}}]},
 {{atom,'FEATURE_AVAILABLE'},
  [{1,
    {['X'],
     [{'(',1},
      {'(',1},
      {var,1,'X'},
      {')',1},
      {'==',1},
      {atom,1,maybe_expr},
      {')',1}]}}]},
 {{atom,'OTP_RELEASE'},{none,[{integer,1,28}]}},
 {{atom,'MACHINE'},{none,[{atom,1,'BEAM'}]}},
 {{atom,'LINE'},{none,[{integer,1,1}]}},
 {{atom,'FILE'},{none,[{string,1,"mod2.erl"}]}},
 {{atom,'MODULE'},{none,[{atom,1,mod2}]}},
 {{atom,'MODULE_STRING'},{none,[{string,1,"mod2"}]}},
 {{atom,'BASE_MODULE'},undefined},
 {{atom,'BASE_MODULE_STRING'},undefined},
 {{atom,'FUNCTION_ARITY'},undefined},
 {{atom,'FUNCTION_NAME'},undefined},
 {{atom,'BEAM'},{none,[{atom,1,true}]}},
 {{atom,'DATA'},
  [{none,{none,[{'<<',4},
                {integer,4,1},
                {',',4},
                {integer,4,2},
                {',',4},
                {integer,4,...},
                {',',...},
                {...}|...]}}]}]
```

Indeed, all the macros have been returned, including the one defined by [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html). The format of the macros stored here can be described below

```erlang
{
  {atom, MacroName},
  {MacroArity, MacroTermOrExprs}
}.
```

The name of the macro is defined in `MacroName` as a `charlist()` type. The next part is the definition of the macro where:

- `MacroArity` is the arity of the macro. If the macro does not have argument, it is set to `none`, else, it is set to a strictly positive integer greater than 0.

- `MacroTermOrExprs` is the content of the macro, it can contain an Erlang term or an expression, and can also contain a variable previously defined in the argument part.

Because `mod2.erl` does not define any macros with arguments, let creates one to see how it is represented.

```erlang
-define(DYN(X,Y,Z), X + Y + Z).
```

This macro when extracted looks like the Erlang term below.

```erlang
{
  {atom,'DYN'},
  [
    {3,
      {['X','Y','Z'],[
        {var,4,'X'},
        {'+',4},
        {var,4,'Y'},
        {'+',4},
        {var,4,'Z'}
      ]}
    }
  ]
}
```

As you can see, this is not so different than the rest of AST, the arguments defined in the macro are expanded in the body of the macro  using the token `{var, Line, ArgumentName}`. Finally, don't forget to close the file to avoid file descriptor exception at the end of this experiment.

```console
> epp:close(EppServer).
ok
```

That's great, it is now possible to extract both records and macros, one from the AST, the other one directly from the preprocessor state. Let find a way to deal with that in Elixir.


# Erlang Records in Elixir

Elixir already has an interface to deal with Erlang records called [`Record`](https://elixir.hexdocs.pm/Record.html). This is working well in most of the case, let just have a look on it. First, a record can only created inside a module, because it uses Elixir meta-programming feature with macros and templates.

```console
$ cat > r.ex << EOF
defmodule R do
  require Record

  Record.defrecord(:test, data: "test")
end
EOF
```

```console
iex> c("r.ex")
[R]

iex> import R
R

iex> R.test()
{:test, "test"}

iex> R.test(:data)
1

iex> R.test() |> R.test(data: "updated")
{:test, "updated"}
```

Okay, great, but now, let check a real-world Erlang records from some very used modules, like [`public_key`](https://www.erlang.org/doc/apps/public_key/public_key.html). Most if not all records are defined in [`public_key/include/public_key.hrl`](https://github.com/erlang/otp/blob/master/lib/public_key/include/public_key.hrl). The first one you will encounter is the `RSAPublicKey` record.

```erlang
-record('RSAPublicKey', {
  modulus,
  publicExponent
 }).
```

Can you see the problem here? When using the Elixir Record module, it creates a function to simulate the behavior of the record, but here, the record identifier is a word starting with an uppercase character. It is not possible to create a function with an uppercase character in Elixir. Just to be sure, a new module containing a function starting with an uppercase letter can be created.

```console
$ cat > up.ex << EOF
defmodule Up do
  def TestFunction(), do: 1
end
EOF
```

```iex
iex> c("up.ex")
== Compilation error in file up.ex ==
** (SyntaxError) invalid syntax found on up.ex:2:19:
    error: unexpected ( after alias TestFunction. Function names and identifiers in Elixir start with lowercase characters or underscore. For example:

        hello_world()
        _starting_with_underscore()
        numb3rs_are_allowed()
        may_finish_with_question_mark?()
        may_finish_with_exclamation_mark!()

    Unexpected token: (
    │
  2 │   def TestFunction(), do: 1
    │                   ^
    │
    └─ up.ex:2:19
    (elixir 1.19.5) lib/kernel/parallel_compiler.ex:530: anonymous fn/5 in Kernel.ParallelCompiler.spawn_workers/8
** (CompileError) compile error
    (iex 1.19.5) lib/iex/helpers.ex:245: IEx.Helpers.c/2
    iex:15: (file)
```

Well, you would probably say something like "not a problem, if it's the only record...", I stop you right there. More than 150 records are using this format in the `public_key` module. Defining 150+ functions is annoying, but because they are all following the same pattern, macros or module templates can be used.

This issue can be solved in many different ways, the first one is to create a function `record/1` where the first argument will contain the record name as an `atom()` starting with an uppercase. Every new record can be added like that.

```console
iex> R.record(:RSAPrivateKey)
{:RSAPrivateKey, :undefined, :undefined}

iex> R.record(:RSAPrivateKey, modulus: 3, publicExponent: 111)
{:RSAPrivateKey, 3, 111}

iex> R.record(:RSAPrivateKey) |> R.record(:modulus, 3)
{:RSAPrivateKey, 3, :undefined}
```

The second solution is the one I prefer. Instead of creating a function containing all record in one place, why not creating a module containing an Elixir struct to represent the record itself? Well, let create the module in charge of that. It will be called [`Preprocessing`](https://github.com/niamtokik/preprocessing) and the sources are already available on github

```elixir
defmodule Preprocessing.Record do
end
```

Listing the available records from an Erlang file is one of the main requirement. To do that, it is possible to mix 2 functions, `:code.lib_dir/1` to get the path of the module, and `:epp.parse_file/2` to parse the Erlang source code. The `list_records/3` function returns all the record identifier as `[atom()]`.

```elixir
  def list_records(module, filepath, opts \\ %{}) do
    case :code.lib_dir(module) do
      {:error, reason} ->
        {:error, reason}
      path ->
        target = Path.join([path, filepath])
        list_records2(module, target, opts)
    end
  end

  defp list_records2(module, target, opts) do
    source_name = Map.get(opts, :source_name, module)
    with true <- File.exists?(target),
         {:ok, tokens} <- :epp.parse_file(target, source_name: source_name)
    do
      for {:attribute, _, :record, {record_name, _}} <- tokens, do: record_name
    else
      false -> {:error, :path};
      other -> other
    end
  end
```

Next, a way to extract the records is required as well. In this case, the `Record.extract/2` can be reused without, it has been created for that.

```elixir
  def extract(module, filepath, record) do
    target = Path.join([Atom.to_string(module), filepath])
    Record.extract(record, from_lib: target)
  end
```

Finally, the module template can be created with the help of the special macro called `__using__/1`. When used on another module, it will generate all the required functions to deal with the imported record.

```elixir
defmacro __using__(opts) do
    record_id = Keyword.get(opts, :record_id)
    module = Keyword.get(opts, :module)
    filepath = Keyword.get(opts, :filepath)
    fields = extract(module, filepath, record_id)
    keys = for {k, _} <- fields, do: k
    values = for {_, v} <- fields, do: v
    tuple = [:record_id] ++ values
      |> List.to_tuple()
      |> Macro.escape()
    record_size = length(fields)+1

    quote do
      import Preprocessing.Record

      defstruct unquote(fields)

      def id(), do: unquote(record_id)

      def fields(), do: unquote(fields)

      def keys(), do: unquote(keys)

      def tuple(), do: unquote(tuple)

      def struct(), do: %__MODULE__{}

      def is_valid?(record) do
        cond do 
          is_tuple(record) and 
            :erlang.size(record) == unquote(record_size) and 
            :erlang.element(1, record) == unquote(record_id) -> true
          true -> false
        end
      end

      def convert(struct = %__MODULE__{}) do
        map = Map.from_struct(struct)
        {:ok, Enum.reduce(fields(), [], fn ({k, _}, acc) -> 
            [Map.get(map, k)|acc]
          end)
          |> Enum.reverse()
          |> (fn(xs) -> [unquote(record_id)|xs] end).()
          |> List.to_tuple()
        }
      end
      def convert(record) when is_tuple(record) do
        if is_valid?(record) do
          record_list =
            Tuple.to_list(record)
            |> Enum.drop(1)

          {:ok, keys()
            |> Enum.zip(record_list)
            |> Enum.reduce(%__MODULE__{}, fn ({k, v}, acc) -> 
              Map.put(acc, k, v)
            end)
          }
        else
          {:error, :invalid_tuple}
        end
      end
      def convert(_), do: {:error, :invalid_term}

      def convert!(record) do
        case convert(record) do
          {:ok, data} -> data
          other -> throw other
        end
      end

    end
  end
```

Great! Let creates our first interface to an existing record. `#RSAPublicKey{}` from the `public_key` module is a good target.

```elixir
defmodule Preprocessing.PublicKey.RSAPublicKey do
  use Preprocessing.Record,
    record_id: :RSAPublicKey,
    module: :public_key,
    filepath: "include/public_key.hrl"
end
```

That's all. The project can now be recompile and it will be possible to test our new module.

```console
iex> alias Preprocessing.PublicKey.RSAPublicKey
Preprocessing.PublicKey.RSAPublicKey

iex> RSAPublicKey.is_valid?({:RSAPublicKey, :undefined, :undefined})
true

iex> RSAPublicKey.is_valid?({:RSAPublicKey})
false

iex> RSAPublicKey.keys()
[:modulus, :publicExponent]

iex> RSAPublicKey.struct()
%PublicKey.RSAPublicKey{
  modulus: :undefined,
  publicExponent: :undefined
}

iex> %RSAPublicKey{}
%RSAPublicKey{
  modulus: :undefined,
  publicExponent: :undefined
}

iex> RSAPublicKey.convert(%RSAPublicKey{})
{:RSAPublicKey, :undefined, :undefined}

iex> RSAPublicKey.convert({:RSAPublicKey, :undefined, :undefined})
%PublicKey.RSAPublicKey{
  modulus: :undefined,
  publicExponent: :undefined
}
```

This module is not perfect though. For example, a function to valid and convert the data correctly from the Elixir struct to the record and vice verse is required. At this time, the developer is in charge of creating the interface for this process. This solution still looks better than the first one. Every new records are treated as individual data-structure defined in their own containers with their own functions. 

# Erlang Macros Definition in Elixir

The Erlang preprocessor macros are not so different than the Erlang records, except when it comes to their arity. In this implementation, only static macros will be supported, but it should not be too complex to implement something with arguments support. Anyway, in a previous section, we saw the macros where stored in the [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) server process state and must be extracted with an undocumented function from the [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) module. In fact, most of the hard work is already done, now, we need a way to integrate them in Elixir.

Static macros are basically made of a key and a value. Why not converting them as [`Map.t()`](https://elixir.hexdocs.pm/Map.html) or [`Keyword.t()`](https://elixir.hexdocs.pm/Keyword.html) in this case? In fact, a macro with the same name than another one present below will overwrite the value of the previous definition. This means it's impossible to have a naming conflict, perfect for a [`Map.t()`](https://elixir.hexdocs.pm/Map.html). First, let creates a new module called `Preprocessing.Macros`, it will contain all the functions required to extract and convert macros, but also a template to include them inside another module.

```elixir
defmodule Preprocessing.Macros do
end
```

The `definitions/2` functions is the only one exported from the module, and will return the converted list of macros as `Map.t()`. This function is used to generate the template but also to find all the macros from a specific module while developing.

```elixir
  def definitions(module, filepath) do
    with {:ok, pid} <- open_file(module, filepath),
      :ok <- definitions_loop(pid),
      {:ok, macros} <- definitions_macros(pid)
    do
      convert_macros(macros, [])
    end
  end
```

All the remaining functions are not exposed to the rest of the application, and are being used to deal with every step of the conversion. The `open_file/2` function is a wrapper around [`:epp.open/2`](https://www.erlang.org/doc/apps/stdlib/epp.html#open/1), checking if a path is available and returning the process id of the `epp` server.

```elixir
  defp open_file(module, filepath) do
    case :code.lib_dir(module) do
      {:error, reason} ->
        {:error, reason}
      path ->
        Path.join([path, filepath])
          |> String.to_charlist()
          |> :epp.open([], [])
    end
  end
```

The `definitions_loop/1` function is quite stupid. It will simply read the content of the opened file until it reaches the end of it. When done, it simply return `:ok`. In fact, this step is very important, because it will load all the macros from the file and store them in the `epp` server's state.

```elixir
  defp definitions_loop(pid) do
    msg = :epp.parse_erl_form(pid)
    case msg do
      {:eof, _} ->
        :ok
      _ ->
        definitions_loop(pid)
    end
  end
```

The `definitions_macros/1` function sends the undocumented `:macro_defs` message to the `eep` server and wait for its answer containing the list of all parsed macros from the source code. Those macros (a list of tuple) is then returned.

```elixir
  defp definitions_macros(pid) do
    send(pid, {:epp_request, self(), :macro_defs})
    receive do
      {:epp_reply, pid, macros} ->
        :epp.close(pid)
        {:ok, macros}
      msg ->
        :epp.close(pid)
        {:error, msg}
      after
        10000 ->
          :epp.close(pid)
          {:error, :timeout}
      end
  end
```

Every raw macros from the [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) server's state must be converted. The `convert_macros/2` and `convert_macros_value/1` functions are doing the conversion and the filtering. Indeed, we are looking only for the static macros right now, not for the one with an arity, then, only the macros set to `:none` are kept, the rest are simply dropped.

```elixir
  defp convert_macros([], buffer) do
    {:ok,
      buffer
      |> Enum.filter(fn({_, v}) ->
        if v==:ignored do
          false
        else
          true
        end
     end)
    }
  end
  defp convert_macros([macro={{:atom, name}, value}|rest], buffer) do
    with {:ok, term} <- convert_macro_value(value) do
      convert_macros(rest, [{name, term}|buffer])
    else
      error -> {:error, error, macro}
    end
  end

  defp convert_macro_value([none: {:none, value}]) do
    with {:ok, term} <- :erl_parse.parse_term(value ++ [{:dot, 1131}]) do
      {:ok, term}
    end
  end
  defp convert_macro_value(_), do: {:ok, :ignored}
```

The `escape_keys/2` function will escape the Erlang macros definitions to insert them safely in the module template via the [`Macro.escape/2`](https://elixir.hexdocs.pm/main/Macro.html#escape/2) function.

```elixir
  defp escape_keys(module, filepath) do
    with {:ok, defs} <- definitions(module, filepath) do
      defs
      |> :maps.from_list()
      |> Macro.escape()
    end
  end
```

The `macro_keys/2` and `macro_values/2` functions are respectively extracting the keys and the values of the macros, converting them into a `[term()]`.

```elixir
  defp macro_keys(module, filepath) do
    with {:ok, defs} <- definitions(module, filepath) do
      defs
      |> Enum.map(fn({k,_}) -> k end)
      |> Macro.escape()
    end
  end

  defp macro_values(module, filepath) do
    with {:ok, defs} <- definitions(module, filepath) do
      defs
      |> Enum.map(fn({_,v}) -> v end)
      |> Macro.escape()
    end
  end
```

The module template definition is probably the most important part here, because it will integrate the data from the Erlang macros into the Elixir AST. 5 functions have been created to help users to check their macros:

- `macros/0`: returns the macros as a `Map.t()`;

- `macro/1`: returns the value of a defined macros using its `key`;

- `macro_keys/0`: returns the list of all macro's keys;

- `macro_values/0`: returns the list of all macro's values;

- `macro_filter/1`: a wrapper around `Map.filter/2` to filter the macros.

```elixir
  defmacro __using__(opts) do
    module = Keyword.get(opts, :module)
    filepath = Keyword.get(opts, :filepath)
    def_keys = escape_keys(module, filepath)

    quote do
      import Preprocessing.Macros

      def macros(), do: unquote(def_keys)

      def macro(index), do: Map.get(unquote(def_keys), index)

      def macro_keys(), do: unquote(macro_keys(module, filepath))

      def macro_values(), do: unquote(macro_values(module, filepath))

      def macros_filter(fun) do
        unquote(def_keys)
        |> Map.filter(fun)
      end
    end
  end
```

Great, the goal now is to create or update a module with this template. The best target here could be the `Preprocessing.PublicKey` module. The module to parse the Erlang macros is `:public_key` and the path for the header is `inclyde/public_key.hrl`.

```elixir
defmodule Preprocessing.PublicKey do
  use Preprocessing.Macros,
    module: :public_key,
    filepath: "include/public_key.hrl"
end
```

Finally, this interface can be tested. The `definitions/2` function returns the correct values from different header files.

```console
iex> alias Preprocessing.Macros
Preprocessing.Macros

iex> Macros.definitions(:kernel, "include/file.hrl")
{:ok, [FILE_HRL_: 1]}

iex> Macros.definitions(:kernel, "include/inet.hrl")
{:ok, []}
```

Let have a look on the `Preprocessing.PublicKey` module now.

```console
iex> alias Preprocessing.PublicKey
alias Preprocessing.PublicKey
```

The `PublicKey.macros/0` function returns all the available macros parsed from the Erlang source code as a [`Map.t()`](https://elixir.hexdocs.pm/Map.html).

```console
iex> PublicKey.macros()
%{
  sect163r1: {1, 3, 132, 0, 2},
  "ub-postal-code-length": 16,
  secp256k1: {1, 3, 132, 0, 10},
  "id-RSAES-OAEP": {1, 2, 840, 113549, 1, 1, 7},
  "id-ce-policyMappings": {2, 5, 29, 33},
  "id-at-pseudonym": {2, 5, 4, 65},
  affiliationChanged: 3,
  "id-at-localityName": {2, 5, 4, 7},
  "id-at-givenName": {2, 5, 4, 42},
  "id-pkix-ocsp-service-locator": {1, 3, 6, 1, 5, 5, 7, 48, 1, 7},
  "ub-name": 32768,
  "id-qt-cps": {1, 3, 6, 1, 5, 5, 7, 2, 1},
  "pbeWithSHA1AndDES-CBC": {1, 2, 840, 113549, 1, 5, 10},
  secp160k1: {1, 3, 132, 0, 9},
  sect409k1: {1, 3, 132, 0, 36},
  "id-ce-extKeyUsage": {2, 5, 29, 37},
  "id-ml-dsa-87": {2, 16, 840, 1, 101, 3, 4, 3, 19},
  emptyString: "",
  ...
}
```

The `PublicKey.macro/1` function is doing its job by returning the value of an existing key, or `nil` if the key is not present.

```console
iex> PublicKey.macro(:sect163r1)
{1, 3, 132, 0, 2}

iex> PublicKey.macro(:undefined)
nil
```

The `PublicKey.macro_keys/0` and `PublicKey.macro_values/0` are returning respectively the keys and the values from the parsed macros.

```elixir
iex> PublicKey.macro_keys()
[:sect163r1, :"ub-postal-code-length", :secp256k1, :"id-RSAES-OAEP",
 :"id-ce-policyMappings", :"id-at-pseudonym", :affiliationChanged, ...]

iex> PublicKey.macro_values
[
  {1, 3, 132, 0, 2},
  16,
  {1, 3, 132, 0, 10},
  {1, 2, 840, 113549, 1, 1, 7},
  ...
]
```

At last, the `PublicKey.macro_filter/1` can filter the keys/values from the macros to return only the one requested via the [`Map.filter/2`](https://elixir.hexdocs.pm/Map.html#filter/2) function. The following snippet is filtering the keys using a [`Regex`](https://elixir.hexdocs.pm/Regex.html)

```console
iex>  PublicKey.macro_filter(fn ({key,_value}) -> 
  cond do
    Regex.match?(~r"^rsa"i, Atom.to_string(key)) -> true; 
    true -> false 
  end 
end)
%{
  "rSASSA-PSS-Default-Identifier": {:"RSASSA-AlgorithmIdentifier",
   {1, 2, 840, 113549, 1, 1, 10},
   {:"RSASSA-PSS-params", {:HashAlgorithm, {1, 3, 14, 3, 2, 26}, :NULL},
    {:MaskGenAlgorithm, {1, 2, 840, 113549, 1, 1, 8},
     {:HashAlgorithm, {1, 3, 14, 3, 2, 26}, :NULL}}, 20, 1}},
  "rSAES-OAEP-Default-Identifier": {:"RSAES-AlgorithmIdentifier",
   {1, 2, 840, 113549, 1, 1, 7},
   {:"RSAES-OAEP-params", {:Externalvaluereference, 354, :"PKCS-1", :sha1},
    {:Externalvaluereference, 355, :"PKCS-1", :mgf1SHA1},
    {:Externalvaluereference, 356, :"PKCS-1", :pSpecifiedEmpty}}},
  rsaEncryption: {1, 2, 840, 113549, 1, 1, 1}
}
```

It is now possible to extract and convert macros from Erlang world to the Elixir universe. This implementation is perhaps not the best one, but it will make my life easier while dealing with the `public_key` module.

# Real World Application

This whole post is the consequence of a sandbox project called [`expki`](https://github.com/niamtokik/expki), created to remove all my rust from years of doing Erlang and infrastructure stuff instead of Elixir. The goal was to use Elixir and Phoenix framework to manage a small local PKI (Public Key Infrastructure) compatible with [`openssl`](https://man.openbsd.org/openssl) and [`easy_rsa`](https://github.com/OpenVPN/easy-rsa), a tool provided by OpenVPN to manage certificates locally. In fact, when this project started, it was expected to have a working PoC quick because Erlang was already offering a good support for TLS with the [`public_key`](www.erlang.org/doc/apps/public_key/public_key.html), [`crypto`](https://www.erlang.org/doc/apps/crypto/crypto.html) and [`asn1`](https://www.erlang.org/doc/apps/asn1/api-reference.html) Erlang applications.

Unfortunately, most of the records name present in those modules are starting with an uppercase letter... and it blocks to create something in a short amount of time. A big part of my time on `expki` was dedicated to read the source code and the documentation of these modules or trying to find a better way to deal with the structure from them. Here the whole list of them extract from an older version of Erlang/OTP.

* from `public_key` (157):
  * `#'AAControls'{}`  
  * `#'ACClearAttrs'{}`                       
  * `#'AccessDescription'{}`
  * `#'AlgorithmIdentifier'{}`
  * `#'AlgorithmIdentifierPKCS5v2{}`
  * `#'AlgorithmIdentifierPKCS{}`
  * `#'AlgorithmIdentifier{}`
  * `#'AnotherName'{}`
  * `#'AttCertValidityPeriod'{}`
  * `#'Attribute'{}`
  * `#'AttributeCertificate'{}`
  * `#'AttributeCertificateInfo'{}`
  * `#'AttributePKCS{}`
  * `#'AttributeTypeAndValue'{}`
  * `#'Attributes_SETOF'{}`
  * `#'Attributes_SETOF_valuesWithContext_SETOF'{}`
  * `#'AuthorityKeyIdentifier'{}`
  * `#'BasicConstraints'{}`
  * `#'BasicOCSPResponse'{}`
  * `#'BuiltInDomainDefinedAttribute'{}`
  * `#'BuiltInStandardAttributes'{}`
  * `#'CertID'{}`
  * `#'Certificate'{}`
  * `#'CertificateList'{}`
  * `#'CertificationRequest'{}`
  * `#'CertificationRequestInfo'{}`
  * `#'CertificationRequestInfo_attributes_SETOF'{}`
  * `#'CertificationRequestInfo_subjectPKInfo'{}`
  * `#'CertificationRequestInfo_subjectPKInfo_algorithm'{}`
  * `#'CertificationRequest_signatureAlgorithm'{}`
  * `#'Characteristic{}`
  * `#'Clearance'{}`
  * `#'ContentEncryptionAlgorithmIdentifier'{}`
  * `#'ContentInfo'{}`
  * `#'Context'{}`
  * `#'CrlID'{}`
  * `#'Curve'{}`
  * `#'DHParameter'{}`
  * `#'DSAPrivateKey'{}`
  * `#'DigestAlgorithm'{}`
  * `#'DigestAlgorithmIdentifier'{}`
  * `#'DigestEncryptionAlgorithmIdentifier'{}`
  * `#'DigestInfoPKCS{}`
  * `#'DigestedData'{}`
  * `#'DistributionPoint'{}`
  * `#'DomainParameters'{}`
  * `#'Dss{}`
  * `#'ECDSA{}`
  * `#'ECParameters'{}`
  * `#'ECPoint'{}`
  * `#'ECPrivateKey'{}`
  * `#'EDIPartyName'{}`
  * `#'EncryptedContentInfo'{}`
  * `#'EncryptedData'{}`
  * `#'EncryptedPrivateKeyInfo'{}`
  * `#'EncryptedPrivateKeyInfo_encryptionAlgorithm'{}`
  * `#'EnvelopedData'{}`
  * `#'ExtendedNetworkAddress_e163{}`
  * `#'Extension'{}`
  * `#'ExtensionAttribute'{}`
  * `#'Extension{}`
  * `#'FieldID'{}`
  * `#'GeneralSubtree'{}`
  * `#'HashAlgorithm'{}`
  * `#'Holder'{}`
  * `#'IetfAttrSyntax'{}`
  * `#'IssuerAndSerialNumber'{}`
  * `#'IssuerSerial'{}`
  * `#'IssuingDistributionPoint'{}`
  * `#'KeyEncryptionAlgorithmIdentifier'{}`
  * `#'MaskGenAlgorithm'{}`
  * `#'NameConstraints'{}`
  * `#'NoticeReference'{}`
  * `#'OCSPRequest'{}`
  * `#'OCSPResponse'{}`
  * `#'ORAddress'{}`
  * `#'OTPAttributeTypeAndValue'{}`
  * `#'OTPCertificate'{}`
  * `#'OTPCharacteristic{}`
  * `#'OTPExtension'{}`
  * `#'OTPExtensionAttribute'{}`
  * `#'OTPFieldID'{}`
  * `#'OTPNoticeReference'{}`
  * `#'OTPOLDSubjectPublicKeyInfo'{}`
  * `#'OTPOLDSubjectPublicKeyInfo_algorithm'{}`
  * `#'OTPSubjectPublicKeyInfo'{}`
  * `#'OTPSubjectPublicKeyInfo{}`
  * `#'OTPTBSCertificate'{}`
  * `#'OTPUserNotice'{}`
  * `#'ObjectDigestInfo'{}`
  * `#'OneAsymmetricKey'{}`
  * `#'OneAsymmetricKey_privateKeyAlgorithm'{}`
  * `#'OtherPrimeInfo'{}`
  * `#'PBEParameter'{}`
  * `#'PBES2{}`
  * `#'PBKDF2{}`
  * `#'PBMAC1{}`
  * `#'PDSParameter'{}`
  * `#'PKAttribute'{}`
  * `#'PKAttribute_valuesWithContext_SETOF'{}`
  * `#'PSourceAlgorithm'{}`
  * `#'Pentanomial'{}`
  * `#'PersonalName'{}`
  * `#'PolicyConstraints'{}`
  * `#'PolicyInformation'{}`
  * `#'PolicyMappings_SEQOF'{}`
  * `#'PolicyQualifierInfo'{}`
  * `#'PreferredSignatureAlgorithm'{}`
  * `#'PresentationAddress'{}`
  * `#'PrivateKeyInfo'{}`
  * `#'PrivateKeyInfo_privateKeyAlgorithm'{}`
  * `#'PrivateKeyUsagePeriod'{}`
  * `#'PublicKeyAlgorithm'{}`
  * `#'RC2{}`
  * `#'RC5{}`
  * `#'RSAES{}`
  * `#'RSAPrivateKey'{}`
  * `#'RSAPublicKey'{}`
  * `#'RSASSA{}`
  * `#'RecipientInfo'{}`
  * `#'Request'{}`
  * `#'ResponseBytes'{}`
  * `#'ResponseData'{}`
  * `#'RevokedInfo'{}`
  * `#'RoleSyntax'{}`
  * `#'SecurityCategory'{}`
  * `#'ServiceLocator'{}`
  * `#'Signature'{}`
  * `#'SignatureAlgorithm'{}`
  * `#'SignatureAlgorithm{}`
  * `#'SignedAndEnvelopedData'{}`
  * `#'SignedData'{}`
  * `#'SignerInfo'{}`
  * `#'SignerInfoAuthenticatedAttributes_aaSequence_SEQOF'{}`
  * `#'SignerInfoAuthenticatedAttributes_aaSet_SETOF'{}`
  * `#'SignerInfo_unauthenticatedAttributes_uaSequence_SEQOF'{}`
  * `#'SignerInfo_unauthenticatedAttributes_uaSet_SETOF'{}`
  * `#'SingleResponse'{}`
  * `#'SubjectPublicKeyInfo'{}`
  * `#'SubjectPublicKeyInfoAlgorithm'{}`
  * `#'SubjectPublicKeyInfo{}`
  * `#'SvceAuthInfo'{}`
  * `#'TBSCertList'{}`
  * `#'TBSCertList_revokedCertificates_SEQOF'{}`
  * `#'TBSCertificate'{}`
  * `#'TBSRequest'{}`
  * `#'TargetCert'{}`
  * `#'TeletexDomainDefinedAttribute'{}`
  * `#'TeletexPersonalName'{}`
  * `#'UnformattedPostalAddress'{}`
  * `#'UserNotice'{}`
  * `#'V2Form'{}`
  * `#'ValidationParms'{}`
  * `#'Validity'{}`
  * `#cert{}`
  * `#path_validation_state{}`
  * `#revoke_state{}`

* from `asn1` (31):
  * `#'ComponentType'{}`
  * `#'Constraint'{}`
  * `#'EXTENSIONMARK'{}`
  * `#'ExtensionAdditionGroup'{}`
  * `#'Externaltypereference'{}`
  * `#'Externalvaluereference'{}`
  * `#'Object'{}`
  * `#'ObjectClassFieldType'{}`
  * `#'ObjectSet'{}`
  * `#'SEQUENCE'{}`
  * `#'SET'{}`
  * `#'SymbolsFromModule'{}`
  * `#abst{}`
  * `#classdef{}`
  * `#cmap{}`
  * `#gen_state{}`
  * `#gen{}`
  * `#module{}`
  * `#objectclass{}`
  * `#pobjectdef{}`
  * `#pobjectsetdef{}`
  * `#ptypedef{}`
  * `#pvaluedef{}`
  * `#pvaluesetdef{}`
  * `#seqtag{}`
  * `#simpletableattributes{}`
  * `#state{}`
  * `#tag{}`
  * `#typedef{}`
  * `#type{}`
  * `#valuedef{}`

That's a lot, right? In reality, not all are required for a Poc, only ~10 or ~20 of them will be used. This is where the `preprocessing` will help, by creating the right interface for the right object. This post is already way to long... And we will see that on another one.

# A Quick Note About `epp_dodger` Module

[`epp_dodger`](https://www.erlang.org/doc/apps/syntax_tools/epp_dodger.html) is another module available in the Erlang OTP toolsuite to parse valid Erlang source code. So, why not using it instead of [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) and all the complexity relative to its server?

Firstly because I wanted to dig a bit more in the Erlang parsing process. Most of my researches were focused on the "default execution path", and I totally missed [`epp_dodger`](https://www.erlang.org/doc/apps/syntax_tools/epp_dodger.html), even if I read the documentation.

Secondly, the [`epp_dodger`](https://www.erlang.org/doc/apps/syntax_tools/epp_dodger.html) module was not loaded by default with `iex` (this module is from the [`syntax_tools`](https://www.erlang.org/docs/18/apps/syntax_tools/index.html) application) and [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) was already available (this module is from the `stdlib` application).

Thirdly, the Erlang toolbox is huge, I don't even think someone know every single tool available there. Every time I start to work on Erlang/OTP source code, I discover new utils.

Finally, it was not planned to implement my own interface to the [`public_key`](https://www.erlang.org/doc/apps/public_key/public_key.html) module, I also missed the [`x509`](https://x509.hexdocs.pm) from hex. In fact, it is also interesting to see the differences between both implementation and it will also give me a way to improve the test suite.

Anyway, let fix that with a quick example of [`epp_dodger`](https://www.erlang.org/doc/apps/syntax_tools/epp_dodger.html) usage. If you want to have it in Elixir, you will need to load the [`syntax_tools`](https://www.erlang.org/docs/18/apps/syntax_tools/index.html) application.

```console
> Application.ensure_all_started(:syntax_tools)
{:ok, [:syntax_tools]}
```

Then, the function [`:epp_dodger.parse_file/1`](https://www.erlang.org/doc/apps/syntax_tools/epp_dodger.html#parse_file/1) can be called

```console
> [:code.lib_dir(:public_key), "include/public_key.hrl"]
  |> Path.join()
  |> :epp_dodger.parse_file()
{:ok,
 [
   {:tree, :attribute, {:attr, 24, [], :none},
    {:attribute, {:atom, 24, :ifndef}, [{:atom, 24, :public_key}]}},
   {:tree, :attribute, {:attr, 25, [], :none},
    {:attribute, {:atom, 25, :define},
     [{:atom, 25, :public_key}, {:atom, 25, true}]}},
   {:tree, :attribute, {:attr, 31, [], :none},
    {:attribute, {:atom, 31, :define},
     [
       {:atom, 31, :"pkcs-1"},
       {:tree, :tuple, {:attr, 31, [], :none},
        [
          {:integer, 31, 1},
          {:integer, 31, 2},
          {:integer, 31, 840},
          {:integer, 31, 113549},
          {:integer, 31, 1},
          {:integer, 31, 1}
        ]}
     ]}},
   {:tree, :attribute, {...}, ...},
   ...
 ]}
```

Now is the better way? I would think using [`epp_dodger`](https://www.erlang.org/doc/apps/syntax_tools/epp_dodger.html) can be a better solution, the [`:epp_dodger.parse_file/1`](https://www.erlang.org/doc/apps/syntax_tools/epp_dodger.html#parse_file/1) function is documented, this is not the case when it comes to the [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html) server solution. I also assume the `epp_dodger` module, because documented, will be more stable in the future than [`epp`](https://www.erlang.org/doc/apps/stdlib/epp.html). In the end, for this first test release, I think it should do the job.

# Conclusion

Even if the interoperability is great between Erlang and Elixir, some part has been ignored or simply discarded because only few people will be interested to use those features. Dealing with Erlang Preprocessor is one of them I guess. In fine, when one knows how Erlang is working, and where to investigate, it becomes an easy problem to fix. Yeah, it can take few hours to understand how the bricks are working, but in the end, it's not lost. Learning how the BEAM is working, and how Erlang is parsed is a fundamental knowledge anyone should have when using this ecosystem.

Long time ago, I worked on an implementation of [ZFS](https://github.com/niamtokik/zfs) (ZettaFileSystem) in Erlang, even if it was working for many things, it was slow and limited to a small amount of the features exposed by ZFS. One of my problem was to deal with all the internal C structure defined in ZFS, evolving sometimes between versions... but also doing mistake by implementing them poorly on the Erlang side as binaries or functions. Having a feature like this one here would have been a game changer, converting a data-structure in C into an Erlang or Elixir function would have be just crazy!

Anyway, as usual, a long list of links if you are interested to know more on this topic:

* [Erlang Code Loading](https://erlang.github.io/prs/9333/doc/system/code_loading.html) from the official Erlang documentation, where you will learn how Erlang code is loaded;

* [Erlang Abstract Format](https://www.erlang.org/doc/apps/erts/absform.html) from the official Erlang documentation, where you will learn what the Erlang abstract form is made of;

* [`erlc` command documentation](https://www.erlang.org/doc/apps/erts/erlc_cmd.html) and [its source code](https://github.com/erlang/otp/blob/master/lib/stdlib/src/erl_compile.erl) from the official Erlang documentation where you will learn how to use the `erlc` command;

* [Core Erlang abstract syntax trees](https://www.erlang.org/doc/apps/compiler/cerl.html) from the official Erlang documentation, where you will learn about the Erlang abstract syntact tree and how to generate ot;

* [The Erlang compiler](https://www.erlang.org/doc/apps/compiler/compile.html) and its [source code](https://github.com/erlang/otp/blob/master/lib/compiler/src/compile.erl) from the official Erlang documentation, where you will learn how the Erlang compiler works;

* [`epp` (erlang preprocessor) documentation](https://www.erlang.org/doc/apps/stdlib/epp.html) and its [source code](https://github.com/erlang/otp/blob/master/lib/stdlib/src/epp.erl) from the official Erlang documentation where you will learn and understand the Erlang preprocessor;

* [`erl_anno` (compiler annotation) documentation](https://www.erlang.org/doc/apps/stdlib/erl_anno.html) and its [source code](https://github.com/erlang/otp/blob/master/lib/stdlib/src/erl_anno.erl) from the official Erlang documentation, where you will learn about the Erlang compiler annotations;

* [`erl_scan` (scanner) documentation](https://www.erlang.org/doc/apps/stdlib/erl_scan.html) and its [source code](https://github.com/erlang/otp/blob/master/lib/stdlib/src/erl_scan.erl) from the official Erlang documentation, where the tokens are produced direct after reading the source code;

* [`erl_parse` (parser) documentation](https://www.erlang.org/doc/apps/stdlib/erl_parse.html) and its [source code](https://github.com/erlang/otp/blob/master/lib/stdlib/src/erl_parse.yrl) from the official Erlang documentation, where the AST is generated from the tokens previously created by the scanner;

* [`io` module documentation](https://www.erlang.org/doc/apps/stdlib/io.html) and its [source code](https://github.com/erlang/otp/blob/master/lib/stdlib/src/io.erl) from the official Erlang documentation, where you can find more information about the I/O protocols;

* [`io_lib` module documentation](https://www.erlang.org/doc/apps/stdlib/io_lib.html) and its [source code](https://github.com/erlang/otp/blob/master/lib/stdlib/src/io_lib.erl) from the official Erlang documentation;

* [`Erlang Abstract Format`](https://github.com/zuiderkwast/erlang_abstract_format) on Github, where you will have another view of the Erlang Abstract Format;

* [The Beam Book](https://github.com/happi/theBeamBook) on Github, where you find a lot of interesting information about the low-level datastructures and how the BEAM is working.

* [`expki` source code](https://github.com/niamtokik/expki) on Github, where the Erlang record and macro issues were found, while developing a PKI manager;

* [`preprocessing` source code](https://github.com/niamtokik/preprocessing) on Github, created while writing this article, and to use it as library on other projects.

Have fun and happy hacking!

----

Cover Image by <a href="https://unsplash.com/@igrindphoto?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Evgeniy Smersh</a> on <a href="https://unsplash.com/photos/a-shelf-filled-with-lots-of-bottles-of-liquid-aWnA944oXLE?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>