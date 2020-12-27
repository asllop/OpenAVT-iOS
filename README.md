# OpenAVT-iOS

[![License](https://img.shields.io/github/license/asllop/OpenAVT-iOS)](https://github.com/asllop/OpenAVT-iOS)


1. [ Introduction ](#intro)
2. [ Installation ](#install)
3. [ Behaviour ](#behav)
4. [ Examples ](#examp)
5. [ Documentation ](#doc)
6. [ Author ](#auth)
7. [ License ](#lice)

<a name="intro"></a>
## 1. Introduction

The Open Audio-Video Telemetry is a set of tools for performance monitoring in multimedia applications. The objectives are similar to those of the OpenTelemetry project, but specifically for sensing data from audio and video players. OpenAVT can be configured to generate Events and Metrics, only Events, only Metrics or a combination of both.

<a name="install"></a>
## 2. Installation

To install OpenAVT-iOS, simply add the following line to your Podfile:

```ruby
pod 'OpenAVT-Core', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

The `OpenAVT-Core` is the base package needed by all the rest, the following packages are available:

#### AVPlayer Tracker

```ruby
pod 'OpenAVT-AVPlayer', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### Google IMA Tracker

```ruby
pod 'OpenAVT-IMA', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

<a name="behav"></a>
## 3. Behaviour

#### The Instrument

In OpenAVT the central concept is the **Instrument**, implemented in the class `OAVTInstrument`. An instrument contains a chain of objects that captures, processes and transmits data from a multimedia player. Each of these three steps is represented by:

- **Trackers**: classes conforming to `OAVTTrackerProtocol`, used to captured data from a specific player. A tracker also keeps its state, an instance of `OAVTState`.

- **Hub**: class conforming to `OAVTHubProtocol`, used to process the data captured by a tracker.

- **Metricalc**: class conforming to `OAVTMetricalcProtocol`, used to calculate metrics. This step is optional.

- **Backend**: class conforming to `OAVTBackendProtocol`, used to transmit data to a data service, database, business intelligence system, storage media, etc.

These objects represents a chain because the data goes from one step to the next in a straight line. The data captured by a tracker is sent to a hub that process it, pass it to a metric calculator and finally it is passed to a backend.

One instrument can contain multiple trackers, but only one hub, one metricalc and one backend.

![Alt text](./oavtinstrument_diag.svg)

An instrument is defined like this:

```swift
let instrument = OAVTInstrument(hub: AnyHub(), metricalc: AnyMetricalc(), backend: AnyBackend())
let tracker1Id = instrument.addTracker(AnyTracker1())
let tracker2Id = instrument.addTracker(AnyTracker2())
let trackerNId = instrument.addTracker(AnyTrackerN())
instrument.ready()
```

The method `OAVTInstrument.ready()` must be called once all the components of the instrument chain are in place. This will cause the execution of the method `OAVTComponentProtocol.instrumentReady(...)` in all trackers, hub, metricalc and backend.

#### The Data

We talked about data being captured and passed along the instrument chain, but what is the nature of this data?

In OpenAVT the main data unit is the **Event**, implemented in the class `OAVTEvent`. An event contains an **Action** (class `OAVTAction`) and a list of **Attributes** (class `OAVTAttribute`).

The action tells us what is the event about, for example when a video starts, an event with the action `OAVTAction.START` is sent.

The attributes offers context for the actions. For example, the attribute `OAVTAttribute.DURATION` informs the stream duration in milliseconds.

OpenAVT can also generate **Metrics**, using an specific step called metricalc (Metric Calculator). A metric is represented by an instance of the class `OAVTMetric`, and is defined by three propeties: name (`String`), value (`Double` or `Int`) and type (`OAVTMetric.MetricType`). An example of metric is `OAVTMetric.START_TIME`, that informs the time elapsed between a video is requested and it actually starts playing.

#### The Chain

The instrument chain describes the steps followed by an event from the moment it is created untill the end of its life.

1. The journey of an event starts with a call to `OAVTInstrument.emit(...)`, that can be called from anywhere, but it's usually called from within a tracker. This function takes an action and a tracker, and generates en event. Initially the event only contains few attributes: the sender ID (that identifies a tracker within an instrument), the timer attributes of previous events and the custom attributes of the instrument created with `OAVTInstrument.addAttribute(...)`.
2. Once the event is created it is sent to the tracker, calling the method `OAVTTrackerProtocol.initEvent(...)`. This method receives an event and returns it, in between it can be tranformed by adding/changing attributes (calling `OAVTEvent.setAttribute(...)`), or even it can stop the chain by returning a nil.
3. The event passed by the tracker is sent to the hub, calling `OAVTHubProtocol.processEvent(...)`. This method works like the previous, it can change the event or block it.
4. If a metricalc is defined, the event is passed to it by calling `OAVTMetricalcProtocol.processMetric(...)`. This method returns an array of metrics (instances of `OAVTMetric`). The array can be empty if no metrics are generated.
5. Finally the event and the metrics are passed to the backend by calling `OAVTBackendProtocol.sendEvent(...)` and `OAVTBackendProtocol.sendMetric(...)`. These methods return nothing, and the chain ends here.

<a name="examp"></a>
## 4. Examples

Inside the `Examples` folder you will find multiple usage examples. To run them execute `pod install` from each example directory.

#### ExampleAVPlayer

Shows how to use the AVPlayer tracker.

#### ExampleAVPlayer+IMA

Shows how to use the AVPlayer tracker and the Google IMA ads tracker.

<a name="doc"></a>
## 5. Documentation

All classes and methods are documented with annotations. To generate the docs in HTML you can use [Jazzy](https://github.com/realm/jazzy), like this:

```bash
jazzy --podspec OpenAVT-Core.podspec --theme fullwidth
```

<a name="auth"></a>
## 6. Author

Andreu Santarén Llop<br>
<andreu.santaren@gmail.com>

<a name="lice"></a>
## 7. License

OpenAVT-iOS is available under the MIT license. See the LICENSE file for more info.
