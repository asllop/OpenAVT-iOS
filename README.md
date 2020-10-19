# OpenAVT-iOS

[![License](https://img.shields.io/github/license/asllop/OpenAVT-iOS)](https://github.com/asllop/OpenAVT-iOS)
[![Language](https://img.shields.io/badge/language-Swift-orange)](https://github.com/asllop/OpenAVT-iOS)

## Introduction

The Open Audio-Video Telemetry is a set of tools for performance monitoring in multimedia applications. The objectives are similar to those of the OpenTelemetry project, but specifically for sensing data from audio and video players.

## Usage

#### The Instrument

In OpenAVT the central concept is the **Instrument**, represented by the class `OAVTInstrument`. An instrument represents a chain of objects that captures, processes and transmits data from a multimedia player. Each of these three steps is represented by:

**Trackers**, classes conforming to `OAVTTrackerProtocol`, used to captured data from a specific player.

**Hubs**, classes conforming to `OAVTHubProtocol`, used to process the data captured by a Tracker. Also keeps a state , an instance of `OAVTState`.

**Backends**, classes conforming to `OAVTBackendProtocol`, used to transmit data processed by a Hub.

These objects represent a chain because the data captured by a tracker is sent to a hub that processes it and passes it away to the backend.

One instrument can contain multiple trackers, but only one hub and one backend. An instrument is defined like this:

```
let instrument = OAVTInstrument(hub: AnyHub(), backend: AnyBackend())
let tracker1Id = instrument.addTracker(AnyTracker1())
let tracker2Id = instrument.addTracker(AnyTracker2())
let trackerNId = instrument.addTracker(AnyTrackerN())
instrument.ready()
```

#### The Data

We talked about data being captured and passed along the instrument chain, but what is the nature of this data?

In OpenAVT the data unit is the **Event**, represented by the class `OAVTEvent`. An event contains an **Action** (class `OAVTAction`) and a list of **Attributes** (class `OAVTAttribute`).

The action tells us what is the event about, for example when a video starts, an event with the action `OAVTAction.START` is sent.

The attributes offers context for the actions. For example, the attribute `OAVTAttribute.DURATION` informs the stream duration in milliseconds.

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

Inside the `Examples` folder you will find multiple usage examples. To run them execute `pod install` from each example directory.

#### ExampleAVPlayer

Shows how to use the AVPlayer tracker.

## Documentation

TODO: create autodocs and tutorials.

## Author

Andreu Santarén Llop<br>
<andreu.santaren@gmail.com>

## License

OpenAVT-iOS is available under the MIT license. See the LICENSE file for more info.
