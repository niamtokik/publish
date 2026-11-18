---
cached_tag_list: "None"
cached_user_name: "None"
cached_user_username: "None"
canonical_url: "https://dev.to/niamtokik/qd-android-device-information-4mpb"
comments_count: "0"
cover_image: "https://media2.dev.to/dynamic/image/width=1000,height=420,fit=cover,gravity=auto,format=auto/https%3A%2F%2Fdev-to-uploads.s3.us-east-2.amazonaws.com%2Fuploads%2Farticles%2Fmr5s79g3lv64i0mk14ha.jpg"
created_at: "None"
crossposted_at: "None"
description: "It can be necessary, sometime, to collect device information, especially to identify a specific kind..."
edited_at: "None"
feed_source_url: "None"
last_comment_at: "None"
main_image: "None"
main_image_background_hex_color: "None"
path: "/niamtokik/qd-android-device-information-4mpb"
public_reactions_count: "0"
published_at: "None"
published: "True"
published_from_feed: "None"
show_comments: "None"
slug: "qd-android-device-information-4mpb"
social_image: "None"
title: "Q&D: Android Device Information"
video: "None"
video_closed_caption_track_url: "None"
video_code: "None"
video_source_url: "None"
video_thumbnail_url: "None"
---

# Q&D: Android Device Information

It can be necessary, sometime, to collect device information, especially to identify a specific kind of device for debugging purpose, or to identify unique devices. In Dart/Flutter, one can install the [`device_info_plus`](https://pub.dev/packages/device_info_plus) package to have access to lot of informations regarding the device where the application is installed. Let have a quick look on this one.

```dart
$ flutter pub add device_info_plus
Resolving dependencies... 
Downloading packages... 
  cupertino_icons 1.0.9 (2.0.0 available)
+ device_info_plus 13.3.0
+ device_info_plus_platform_interface 8.1.0
+ ffi 2.2.0
+ ffi_leak_tracker 0.1.2
+ file 7.0.1
+ flutter_web_plugins 0.0.0 from sdk flutter
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.18.3 (1.19.0 available)
+ plugin_platform_interface 2.1.8
  test_api 0.7.12 (0.7.15 available)
  vector_math 2.4.2 (2.4.3 available)
+ web 1.1.1
+ win32 6.4.0
+ win32_registry 3.0.3
Changed 10 dependencies!
5 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
```

The first step is to import the `device_info_plus` package in your code.

```dart
import 'package:device_info_plus/device_info_plus.dart';
```

One can extract only a small subset of all device information available, for example, to extract the device [`id`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/id.html), the [`id`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/id.html) property can be retrieved and returned.

```dart
Future<String> getDeviceId() {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String deviceInfo = await deviceInfoPlugin.deviceInfo;
  return deviceInfo.id;
}
```

If more information about a device is required, one can extract all of them as a `Map<String, dynamic>` using the [`data`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/BaseDeviceInfo/data.html) property.

```dart
Future<Map<String, dynamic>> getDeviceInfoMap() {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  BaseDeviceInfo deviceInfo = await deviceInfoPlugin.deviceInfo;
  return deviceInfo.data;
}
```

Some information are only available on a specific kind of device (e.g. iOS, Android, Browser). If the application has been developed with portability in mind, it can also be a good idea to extract device's information based on the architecture/platform.

```dart
Future<Map<String, dynamic>> getAndroidDeviceInfoMap() {
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  AndroidDeviceInfo deviceInfo = await deviceInfoPlugin.androidInfo;
  return deviceInfo.data;
}
```

Here an example of the data extracted on an Android emulator:
```console
I/flutter ( 3959): physicalRamSize: 2472
I/flutter ( 3959): type: user
I/flutter ( 3959): manufacturer: Google
I/flutter ( 3959): freeDiskSize: 464072704
I/flutter ( 3959): bootloader: unknown
I/flutter ( 3959): fingerprint: google/sdk_gphone64_x86_64/emu64xa:16/BE2A.250530.026.D1/13818094:user/release-keys
I/flutter ( 3959): host: e8e8f3751cda
I/flutter ( 3959): isLowRamDevice: false
I/flutter ( 3959): model: sdk_gphone64_x86_64
I/flutter ( 3959): id: BE2A.250530.026.D1
I/flutter ( 3959): brand: google
I/flutter ( 3959): hardware: ranchu
I/flutter ( 3959): product: sdk_gphone64_x86_64
I/flutter ( 3959): totalDiskSize: 6228115456
I/flutter ( 3959): supportedAbis: [x86_64, arm64-v8a]
I/flutter ( 3959): supported32BitAbis: []
I/flutter ( 3959): display: BE2A.250530.026.D1
I/flutter ( 3959): isPhysicalDevice: false
I/flutter ( 3959): version: {baseOS: , securityPatch: 2025-07-05, sdkInt: 36, release: 16, codename: REL, previewSdkInt: 0, incremental: 13818094}
I/flutter ( 3959): systemFeatures: [android.hardware.sensor.proximity, android.software.adoptable_storage, android.hardware.sensor.accelerometer, android.software.controls, android.hardware.faketouch, android.software.telecom, android.hardware.telephony.subscription, android.hardware.reboot_escrow, android.hardware.telephony.data, android.software.backup, android.hardware.touchscreen, android.hardware.touchscreen.multitouch, android.software.erofs, android.software.print, android.software.activities_on_secondary_displays, android.software.device_lock, android.software.voice_recognizers, android.software.picture_in_picture, android.hardware.fingerprint, android.hardware.sensor.gyroscope, com.google.android.feature.PERSONAL_SAFETY, android.software.vulkan.deqp.level, android.software.cant_save_state, android.hardware.security.model.compatible, android.hardware.telephony.messaging, android.hardware.telephony.calling, android.hardware.sensor.relative_humidity, android.hardware.bluetooth, android.software.window_magnification, andr
I/flutter ( 3959): tags: release-keys
I/flutter ( 3959): supported64BitAbis: [x86_64, arm64-v8a]
I/flutter ( 3959): availableRamSize: 967
I/flutter ( 3959): name: sdk_gphone64_x86_64
I/flutter ( 3959): time: 1753213259000
I/flutter ( 3959): device: emu64xa
I/flutter ( 3959): board: goldfish_x86_64
```

More information can be found on Android via the [`AndroidBuildVersion`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidBuildVersion-class.html) object (including the base name, the code name and the release).

Depending on the platform, a lot of values can be extracted. Here a quick list enumerating few of them (the ones the most interesting to me):

* [`AndroidDeviceInfo`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo-class.html#instance-properties):

  * [`availableRamSize`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/availableRamSize.html) as `int`: Current unallocated RAM size of the device in megabytes, extracted from [`ActivityManager.MemoryInfo`](https://developer.android.com/reference/android/app/ActivityManager.MemoryInfo#availMem);

 * [`board`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/board.html) as `String`: The name of the underlying board, like "goldfish", extracted from [`Build.BOARD`](https://developer.android.com/reference/android/os/Build#BOARD);

 * [`brand`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/brand.html) as `String`: The consumer-visible brand with which the product/hardware will be associated, if any, extracted from [`Build.BRAND`](https://developer.android.com/reference/android/os/Build#BRAND);

 * [`device`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/device.html) as `String`: The name of the industrial design, extracted from [`Build.DEVICE`](https://developer.android.com/reference/android/os/Build#DEVICE);

 * [`fingerprint`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/fingerprint.html) as `String`: A string that uniquely identifies this build (Do not attempt to parse this value.), extracted from [`Build.FINGERPRINT`](https://developer.android.com/reference/android/os/Build#FINGERPRINT);

 * [`hardware`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/hardware.html) as `String`: The name of the hardware (from the kernel command line or /proc), extracted from [`Build.HARDWARE`](https://developer.android.com/reference/android/os/Build#HARDWARE);

 * [`manufacturer`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/manufacturer.html) as `String`: The manufacturer of the product/hardware, extracted from [`Build.MANUFACTURER`](https://developer.android.com/reference/android/os/Build#MANUFACTURER);

 * [`version`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidDeviceInfo/version.html) as [`AndroidBuildVersion`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/AndroidBuildVersion-class.html): Android operating system version values derived from `android.os.Build.VERSION`;


* [`IosDeviceInfo`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/IosDeviceInfo-class.html)

 * [`identifierForVendor`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/IosDeviceInfo/identifierForVendor.html): Unique UUID value identifying the current device;

 * [`modelName`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/IosDeviceInfo/modelName.html): Commercial or user-known model name Examples: iPhone 16 Pro, iPad Pro 11-Inch 3;

 * [`utsname`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/IosDeviceInfo/utsname.html): Operating system information derived from sys/utsname.h;

* [`LinuxDeviceInfo`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/LinuxDeviceInfo-class.html)

 * [`id`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/LinuxDeviceInfo/id.html): A lower-case string identifying the operating system, excluding any version information and suitable for processing by scripts or usage in generated filenames;

 * [`machineId`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/LinuxDeviceInfo/machineId.html): A unique machine ID of the local system that is set during installation or boot. The machine ID is hexadecimal, 32-character, lowercase ID;


* [`MacOsDeviceInfo`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/MacOsDeviceInfo-class.html)

 * [`systemGUID`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/MacOsDeviceInfo/systemGUID.html): Device GUID;

* [`WindowsDeviceInfo`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/WindowsDeviceInfo-class.html)

 * [`deviceId`](https://pub.dev/documentation/device_info_plus/latest/device_info_plus/WindowsDeviceInfo/deviceId.html): Displayed as "Device ID" in Windows Setting

The next step will be to generate an unique reproducible identifier from different systems using those information. A list of resources to help thinking about all of that:

- [Best practices for unique identifiers](https://developer.android.com/identity/user-data-ids) from the official Android Developers Website;

- [Identifying App Installations](https://android-developers.googleblog.com/2011/03/identifying-app-installations.html) from the official Android developers blog;

- [`android-unique-device-id`](https://github.com/cesarferreira/android-unique-device-id) on github;

- [Unique ID of Android device](https://stackoverflow.com/questions/4468248/unique-id-of-android-device) on StackOverflow;

- [Generate a unique Android Device ID](https://gist.github.com/tokoiwesley/27a644312fe657626996f4af0b77a276) on gist;



As usual, happy hacking!

----

Cover image by <a href="https://unsplash.com/@elena_ramseier?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Elena Ramseier</a> on <a href="https://unsplash.com/photos/a-large-group-of-green-chairs-1xk8hMP-WHo?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>