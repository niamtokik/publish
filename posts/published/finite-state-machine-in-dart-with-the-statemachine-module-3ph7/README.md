---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/finite-state-machine-in-dart-with-the-statemachine-module-3ph7"
comments_count: "4"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.amazonaws.com%2Fuploads%2Farticles%2Fiuvfy71e6usdd00yn5d4.jpg"
created_at: "None"
crossposted_at: "None"
description: "You already know, Erlang is my favorite language... You should also probably know Erlang uses finite..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/finite-state-machine-in-dart-with-the-statemachine-module-3ph7"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "finite-state-machine-in-dart-with-the-statemachine-module-3ph7"
social_image: "None"
title: "Finite State Machine in Dart with the state_machine module"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Finite State Machine in Dart with the state_machine module

You already know, Erlang is my favorite language... You should also probably know Erlang uses [finite state machines](https://en.wikipedia.org/wiki/Finite-state_machine) as one of its core concept? In fact, it's probably why one can't come back from Erlang, when you know how to use them, everything becomes easier. This kind of pattern is not only available in Erlang, and few implementations exist on Dart. Here the interesting ones found on pub.dev and github:

| project | version | documentation | source code |
|---------|---------|---------------|-------------|
| [`state_machine`](https://pub.dev/packages/state_machine) | `3.0.3` | [documentation](https://pub.dev/documentation/state_machine/latest/) | [source code](https://github.com/Workiva/state_machine) |
| [`statemachine`](https://pub.dev/packages/statemachine) | `3.4.0` | [documentation](https://pub.dev/documentation/statemachine/latest/) | [source code](https://github.com/renggli/dart-statemachine) |
| [`automata`](https://pub.dev/packages/automata) | `0.2.0` | [documentation](https://pub.dev/documentation/automata/latest/) | - |
| [`dart_fsm`](https://pub.dev/packages/dart_fsm) | `1.3.1` | [documentation](https://pub.dev/documentation/dart_fsm/latest/) | [source code](https://github.com/team-lab/dart_fsm) |
| [`immutable_fsm`](https://pub.dev/packages/immutable_fsm) | `1.1.0` | [documentation](https://pub.dev/documentation/immutable_fsm/latest/) | [source code](https://github.com/zysoft/immutable_fsm) |

The most used of those project is `state_machine` with more than 22k download, then, this will be the first one to be tested in this article.

# Bootstrapping

```console
$ dart create fsm
Creating fsm using template console...

  .gitignore
  analysis_options.yaml
  CHANGELOG.md
  pubspec.yaml
  README.md
  bin/fsm.dart
  lib/fsm.dart
  test/fsm_test.dart

Running pub get...                     1.1s
  Resolving dependencies...
  Downloading packages...
  Changed 48 dependencies!

Created project fsm in fsm! In order to get started, run the following commands:

  cd fsm
  dart run

$ cd fsm

$ dart pub add state_machine
Resolving dependencies... 
Downloading packages... 
+ clock 1.1.2
+ intl 0.20.3
+ js 0.6.7 (0.7.2 available)
+ state_machine 3.0.3
+ w_common 4.0.0
Changed 5 dependencies!
1 package has newer versions incompatible with dependency constraints.
Try `dart pub outdated` for more information.
```

The only required header to add in all your code requiring this module:

```dart
import 'package:state_machine/state_machine.dart';
```

# Usage

The first step is to create a new [`StateMachine`](https://pub.dev/documentation/state_machine/latest/state_machine/StateMachine-class.html) object. Only one argument is required for the [constructor](https://pub.dev/documentation/state_machine/latest/state_machine/StateMachine/StateMachine.html), the state machine name.

When a state machine changes its state, the [`onStateChange`](https://pub.dev/documentation/state_machine/latest/state_machine/StateMachine/onStateChange.html) parameter is receiving the event, and then, react on it.

```dart
// create a new state machine
StateMachine fsm = StateMachine('fsm');

// react on state change with a closure
final onStateChange = (StateChange change) {
    print('onStateChange: $change');
};  
fsm.onStateChange.listen(onStateChange);
```

The second step is to create a new [`State`](https://pub.dev/documentation/state_machine/latest/state_machine/State-class.html) objects representing respectively all accepted state by the state machine. To do that, the [`newState()`](https://pub.dev/documentation/state_machine/latest/state_machine/StateMachine/newState.html) method must be called. The only argument to pass is the name of the state.

During a transition, the state machine can enter into a new state or leave an old state. Those two kind of events can be followed by configuring respectively the [`onEnter`](https://pub.dev/documentation/state_machine/latest/state_machine/State/onEnter.html) and [`onLeave`](https://pub.dev/documentation/state_machine/latest/state_machine/State/onLeave.html) parameters.

```dart
// enter state closure
final onEnter = (StateChange change) {
  print('onEnter: $change');
};

// leave state closure
final onLeave = (StateChange change) {
  print('onLeave: $change');
};  

// create a state called init
State init = fsm.newState('init');
init.onEnter.listen(onEnter);
init.onLeave.listen(onLeave);

// create a state called count
State count = fsm.newState('count');
count.onEnter.listen(onEnter);
count.onLeave.listen(onLeave);

// create a state called stop
State stop = fsm.newState('stop');
stop.onEnter.listen(onEnter);
stop.onLeave.listen(onLeave);
```

The transition between states can then be created. They are represented by [`StateTransition`](https://pub.dev/documentation/state_machine/latest/state_machine/StateTransition-class.html) objects. This is the most "complex" method there, because the method [`newStateTransition`](https://pub.dev/documentation/state_machine/latest/state_machine/StateMachine/newStateTransition.html) requires 3 arguments. One is the name of the transition as a string, the second is the list of allowed states before the transition, and the last one is the next state after the transition.

```dart
StateTransition counting = fsm.newStateTransition('counting', [init,count], count);
StateTransition stopping = fsm.newStateTransition('stopping', [count], stop);
```

Then, the state machine can be started by calling the [`start()`](https://pub.dev/documentation/state_machine/latest/state_machine/StateMachine/start.html) method. The only argument used here is a reference to the starting state.

```dart
fsm.start(init);
```

The transitions can now be called using the previous objects created. It is also possible to pass an argument to them as a payload.

```dart
// calling the counting transition
counting(1);
counting(2);
counting(3);
counting(4);

// calling the stopping transition
stopping();
```

When the state machine is terminated, one should use the [`dispose()`](https://pub.dev/documentation/state_machine/latest/state_machine/StateMachine/dispose.html) method to clean up the memory and avoid memory leaks.

```dart
fsm.dispose();
```

The code looks okay. Let execute it to see what will happen.

```console
$ dart run
...
onStateChange: StateChange: (none) --> init

onEnter: StateChange: (none) --> init

onStateChange: StateChange: init --> count
    payload: 1

onLeave: StateChange: init --> count
    payload: 1

onStateChange: StateChange: count --> count
    payload: 2

onLeave: StateChange: count --> count
    payload: 2

onStateChange: StateChange: count --> count
    payload: 3

onLeave: StateChange: count --> count
    payload: 3

onStateChange: StateChange: count --> count
    payload: 4

onLeave: StateChange: count --> count
    payload: 4

onStateChange: StateChange: count --> stop

onLeave: StateChange: count --> stop

onEnter: StateChange: count --> stop

onDispose: null
```

As you can see, the different steps are displayed on the screen, and we can see each state transitions. If an illegal transition happens in a specific state, the state machine throw an exception.

# Conclusion

`state_machine` just works, but the way the state machine, the transitions and the events triggering the transitions are created annoys me a bit, perhaps because it's the OOP way to do it.

Indeed, to me, a great implementation of a state machine is from Erlang, with [`gen_statem`](https://www.erlang.org/doc/apps/stdlib/gen_statem.html), a state machine should embed its "data" or "state" and those elements should be modified during a transition.

Anyway, if you want to know more about the `state_machine` package, here few links:

- [`state_machine` package](https://pub.dev/packages/state_machine) on pub.dev;

- [`state_machine` official API documentation](https://pub.dev/documentation/state_machine/latest/) on pub.dev;

- [`state_machine` source code](https://github.com/Workiva/state_machine) on Github;

- [`state_machine` example source code](https://github.com/Workiva/state_machine/tree/master/example) on Github;

- [`state_machine` test suite source code](https://github.com/Workiva/state_machine/tree/master/test) on Github.

Have fun and happy hacking!

----

Cover Image by <a href="https://unsplash.com/@mikehindle?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Mike Hindle</a> on <a href="https://unsplash.com/photos/black-metal-gear-on-black-metal-tool-OIwLUSQj4b0?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>