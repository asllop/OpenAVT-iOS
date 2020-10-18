# OpenAVT-iOS

[![License](https://img.shields.io/github/license/asllop/OpenAVT-iOS)](https://github.com/asllop/OpenAVT-iOS)
[![Language](https://img.shields.io/badge/Language-Swift-orange)](https://github.com/asllop/OpenAVT-iOS)
[![Last Commit](https://img.shields.io/github/last-commit/asllop/OpenAVT-iOS)](https://github.com/asllop/OpenAVT-iOS)

## Introduction

The Open Audio-Video Telemetry is a set of tools for performance monitoring in multimedia applications. The objectives are similar to those of the OpenTelemetry project, but specifically for audio and video players.

## Structure

TODO: explain how OpenAVT works. Instruments, Trackers, Hubs and Backends.

## Installation

To install OpenAVT-iOS, simply add the following line to your Podfile:

```ruby
pod 'OpenAVT-Core', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

The `OpenAVT-Core` is the base package, needed by all the rest. But you also need to add pods for the specific OpenAVT components you will use in your project.

The following packages are available:

#### AVPlayer Tracker

```ruby
pod 'OpenAVT-AVPlayer', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### Google IMA Tracker

```ruby
pod 'OpenAVT-IMA', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

## Examples

TODO: create examples

## Documentation

TODO: create docs

## Author

Andreu Santarén Llop<br>
<andreu.santaren@gmail.com>

## License

OpenAVT-iOS is available under the MIT license. See the LICENSE file for more info.
