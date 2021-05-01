# OpenAVT-iOS

[![License](https://img.shields.io/github/license/asllop/OpenAVT-iOS)](https://github.com/asllop/OpenAVT-iOS)


1. [ Introduction ](#intro)
2. [ Installation ](#install)
3. [ Usage ](#usage)
4. [ Behaviour ](#behav)
5. [ Data Model ](#model)
6. [ Examples ](#examp)
7. [ Documentation ](#doc)
8. [ Author ](#auth)
9. [ License ](#lice)

<a name="intro"></a>
## 1. Introduction

The Open Audio-Video Telemetry is a set of tools for performance monitoring in multimedia applications. The objectives are similar to those of the OpenTelemetry project, but specifically for sensing data from audio and video players. OpenAVT can be configured to generate Events, Metrics or a combination of both.

<a name="install"></a>
## 2. Installation

To install OpenAVT-iOS, simply add the following line to your Podfile:

```ruby
pod 'OpenAVT-Core', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

Besides the Core, the following modules are available:

#### AVPlayer Tracker

Tracker for the AVPlayer video and audio player.

```ruby
pod 'OpenAVT-AVPlayer', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### Google IMA Tracker

Tracker for the Google IMA ads library.

```ruby
pod 'OpenAVT-IMA', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### Graphite Backend

Backend for the Graphite metrics database.

```ruby
pod 'OpenAVT-Graphite', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### InfluxDB Backend

Backend for the InfluxDB metrics database.

```ruby
pod 'OpenAVT-InfluxDB', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### New Relic Backend

Backend for the New Relic data ingestion service.

```ruby
pod 'OpenAVT-NewRelic', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

<a name="usage"></a>
## 3. Usage

There are many ways to use the OpenAVT library, depending on the use case, here we will cover the most common combinations. We won't explain all the possible arguments passed to the constructors, only the essential ones. For the rest check out the [documentation](#doc).

### Choosing a Backend

The first step is chosing the backend where the data will be sent. We currenly support OOTB three different backends: Graphite, InfluxDB and New Relic. Let's see how to init them:

#### Init the Graphite Backend

```swift
let backend = OAVTBackendGraphite(host: "192.168.99.100")
```

`host` is the address of the Graphite server.

#### Init the InfluxDB Backend

```swift
let backend = OAVTBackendInfluxdb(url: URL(string: "http://192.168.99.100:8086/write?db=test")!)
```

`url` is the URL of the InfluxDB server used to write data to a particular database (in this case named `test`).

#### Init the New Relic Backend

```swift
let backend = OAVTBackendNewrelic()
```

The New Relic Mobile Agent must be installed and setup to use this backend.

### Choosing a Hub

Next we will choose a Hub. This element is used to obtain the data comming from the trackers and process it to pass the proper events to the backend. Users can implement their own logic for this and use their own custom hubs, but OpenAVT provides a default implementation that works for most cases.

For instruments with video tracker only, we will chose:

```swift
let hub = OAVTHubCore()
```

And for instruments with video and ads tracker:

```swift
let hub = OAVTHubCoreAds()
```

### Choosing a Metricalc

This step is optional and only necessary if we want to generate metrics, if we only need events this section can be omitted. A Metricalc is something like a Hub but for metrics, it gets events and process them to generate metrics. Again, users can provide custom implementation, but the OpenAVT library provides a default one:

```swift
let metricalc = OAVTMetricalcCore()
```

### Choosing Trackers

And finally, the trackers, the piece that actually generates the data. Currently OpenAVT provides two trackers: AVPlayer and Google IMA Ads. We won't cover how to setup the AVPlayer and IMA libraries, for this checkout the correspondig documentation or the [examples](#examp).

#### Init the AVPlayer Tracker

```swift
let tracker = OAVTTrackerAVPlayer(player: avplayer)
```

Where `player` is an instance of the AVPlayer.

#### Init the IMA Tracker

```swift
let adTracker = OAVTTrackerIMA()
```

### Creating the Instrument

Once we have all the elements, the only step left is putting everything together:

```swift
let instrument = OAVTInstrument(hub: hub, metricalc: metricalc, backend: backend)
instrument.addTracker(tracker)
instrument.addTracker(adTracker)
instrument.ready()
```

Here we have created a new instrument that contains all the elements, and once all are present, we called `ready()` to initialize everything. Now the instrument is ready to start generating data.

<a name="behav"></a>
## 4. Behavior

#### The Instrument

In OpenAVT the central concept is the **Instrument**, implemented in the class `OAVTInstrument`. An instrument contains a chain of objects that captures, processes and transmits data from a multimedia player. Each of these three steps is represented by:

- **Trackers**: classes conforming to `OAVTTrackerProtocol`, used to capture data from a specific player. A tracker also keeps its state in an instance of `OAVTState` (but shouldn't modify it, this is a job for the Hub).

- **Hub**: class conforming to `OAVTHubProtocol`, it contains the business logic. Is used to process the data captured by a tracker, update states and tranform events if necessary.

- **Metricalc**: class conforming to `OAVTMetricalcProtocol`, used to calculate metrics. This step is optional.

- **Backend**: class conforming to `OAVTBackendProtocol`, used to transmit data to a data service, database, business intelligence system, storage media or similar.

These objects represents a chain because the data goes from one step to the next in a straight line. The data captured by a tracker is sent to the hub, then it goes to the metric calculator and finally to the backend.

One instrument can contain multiple trackers, but only one hub, one metricalc and one backend.

![Alt text](./oavtinstrument_diag.svg)

An instrument like the one in the figure would be defined like this:

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

Both, `OAVTEvent` and `OAVTMetric`, are **Samples**, subclasses of `OAVTSample`. A sample essentially defines a datum captured at a certain moment, and its sole property is the timestamp.

#### The Chain

The instrument chain describes the steps followed by an event from the moment it is created untill the end of its life.

1. The journey of an event starts with a call to `OAVTInstrument.emit(...)`, that can be called from anywhere, but it's usually called from within a tracker. This function takes an action and a tracker, and generates en event. Initially the event only contains few attributes: the sender ID (that identifies a tracker within an instrument), the timer attributes of previous events and the custom attributes of the instrument created with `OAVTInstrument.addAttribute(...)`.
2. Once the event is created it is sent to the tracker, calling the method `OAVTTrackerProtocol.initEvent(...)`. This method receives an event and returns it, in between it can be tranformed by adding/changing attributes (calling `OAVTEvent.setAttribute(...)`), or even it can stop the chain by returning a nil.
3. The event passed by the tracker is sent to the hub, calling `OAVTHubProtocol.processEvent(...)`. This method works like the previous, it takes an event and returns it and in between it can be tranformed, blocked, etc.
4. If a metricalc is defined, the event is passed to it by calling `OAVTMetricalcProtocol.processMetric(...)`. This method returns an array of metrics (instances of `OAVTMetric`). The array can be empty if no metrics are generated.
5. Finally the event and the metrics are passed to the backend by calling `OAVTBackendProtocol.sendEvent(...)` and `OAVTBackendProtocol.sendMetric(...)`. These methods return nothing, and the chain ends here.

<a name="model"></a>
## 5. Data Model

The Data Model describes all the data an instrument could generate and the meaning of each piece of information.

#### The telemetry dilemma: Events or Metrics?

First let's define what are Events and Metrics in the context of OpenAVT. Both are time series data, but there are some differences:

An **Event** is an heterogeneous structure of data. It contains a list of key-value pairs, where the key is always a string but the value could be of any type: integer, float, string or boolean. Two events of the same type (or how they are called in OpenAVT, same **Action**), may contain different combinations of key-value pairs (**Attributes**, as they are called in OpenAVT).

A **Metric** on the other side is homogeneous, there is one single value per metric and it's always numeric (integer or float). Two metrics of the same type have always the same kind of data.

Choosing between events and metrics depends on many factors: the kind of calculations we want to do, the amount of data we can store, how often we are going to update our KPIs, where we are going to store our data (the choosen backend), etc.

In general events offer more flexibility to calculate important indicators. We have almost "raw" information, so if we want to make some KPI calculations today, but our needs changes over time, it's possible to update the queries on the recorded data without having to change the instrument code. The main disadvantage of events is that they consume lots of space, so our database will grow rapidly.

Metrics are small and doesn't get too much space on a database. Queries over metrics are also much faster to process. But the information we store is very specific and, in general, with metrics we have to hardcode the KPIs we want to generate in the instrument side. If these needs change, we will face the problem of updating the instrument code. In OpenAVT this jobs is done in the **Metricalc**.

Also, some backends can work better with (or only support) one kind of data. For example, Graphite only offers support for metrics (that's actually not true, it supports events, but they are so limited that doesn't fit the needs of OpenAVT Events).

#### Events

Events indicate that something happened in the tracker lifecycle and player workflow. Each event has a type, that in OpenAVT is called Action. The following is an exhaustive list of the available actions.

| Action | Description |
| ------ | ----------- |
| `TRACKER_INIT` | A tracker has been initialized. |
| `PLAYER_SET` | A player instance has been passed to the tracker. |
| `PLAYER_READY` | The player instance is ready to start generating events. |
| `MEDIA_REQUEST` | An audio/video stream has been requested, usually by the user (tapping an hypothetical play button or similar in the app). |
| `PREPARE_ITEM` | The player is preparing an item to be loaded/played. Not all players support this action. |
| `MANIFEST_LOAD` | The manifest is being loaed. Not all players support this action. |
| `STREAM_LOAD` | An audio/video stream is being loaded. |
| `START` | Stream has started, first frame shown. |
| `BUFFER_BEGIN` | Player started buffering. |
| `BUFFER_FINISH` | Player ended buffering. |
| `SEEK_BEGIN` | Started seeking. |
| `SEEK_FINISH` | Ended seeking. |
| `PAUSE_BEGIN` | Stream paused. |
| `PAUSE_FINISH` | Stream resumed. |
| `FORWARD_BEGIN` | Fast forward begin. Not all players support this action. |
| `FORWARD_FINISH` | Fast forward finish. Not all players support this action. |
| `REWIND_BEGIN` | Fast rewind begin. Not all players support this action. |
| `REWING_FINISH` | Fast rewind finish. Not all players support this action. |
| `QUALITY_CHANGE_UP` | Stream quality (resolution) increased. |
| `QUALITY_CHANGE_DOWN` | Stream quality (resolution) degraded. |
| `STOP` | Playback has been stopped. |
| `END` | Stream reached the end. |
| `NEXT` | Next stream in a playlist is going to be loaded. Not all players support this action. |
| `ERROR` | An error happened. |
| `PING` | Sent every 30 seconds from `START` to `END`/`STOP`. |
| `AD_BREAK_BEGIN` | An ad break (block) has started. An ad break may contain multiple ads. |
| `AD_BREAK_FINISH` | Ad break finished. |
| `AD_BEGIN` | Ad started, first framr shown. |
| `AD_FINISH` | Ad ended. |
| `AD_PAUSE_BEGIN` | Ad paused. |
| `AD_PAUSE_FINISH` | Ad resumed. |
| `AD_BUFFER_BEGIN` | Ad started buffering. |
| `AD_BUFFER_FINISH` | Ad ended buffering. |
| `AD_SKIP` | Ad skipped. |
| `AD_CLICK` | User tapped on the ad. |
| `AD_FIRST_QUARTILE` | Ad reched the first quartile. |
| `AD_SECOND_QUARTILE` | Ad reched the second quartile. |
| `AD_THIRD_QUARTILE` | Ad reched the third quartile. |
| `AD_ERROR` | An error happened during ad playback. |

The common workflow of events for most playbacks is as follows:

1. `TRACKER_INIT` when the tracker is ready.
2. `PLAYER_SET` when the player instance is passed to the tracker.
3. `PLAYER_READY` when all listeners has been set and the player is ready to generate events.
4. `STREAM_LOAD` when a stream starts loading.
5. `START` when the stream ends loading and starts playing.
6. After it, can happen any number of the following blocks: `BUFFER_BEGIN`/`BUFFER_FINISH`, `PAUSE_BEGIN`/`PAUSE_FINISH` or `SEEK_BEGIN`/`SEEK_FINISH`. Also can hapen quality changes (`QUALITY_CHANGE_UP`, `QUALITY_CHANGE_DOWN`).
7. Finally a `STOP` or an `END` will happen when the stream is stopped by the user or it ends.

An `ERROR` can happen at any time during the player lifecycle. An error usually implies the end of the playback, so use to be followed by an `END`.

An ad block can happen at any time during the content playback. The workflow of ads is as follows:

1. `AD_BREAK_BEGIN` when the block starts.
2. `AD_BEGIN` when an ad starts.
3. `AD_FIRST_QUARTILE`, `AD_SECOND_QUARTILE` and `AD_THIRD_QUARTILE` when the corresponding quartiles are reached.
4. `AD_END` when the ad reaches the end.
5. After it, if there are more ads in the block, the workflow start again on 2.
6. When all ads are played, an `AD_BREAK_FINISH` is sent.

An `AD_SKIP` when the user skips the ad can happen at any time.
An `AD_CLICK` when the user taps the ad can happen at any time.
An `AD_ERROR` can happen at any time and is usually followed by `AD_END`.

#### Attributes

As we already said, en event is composed out of an action and a list of attributes. Here we present the list of attributes generated by OpenAVT.

Note: Times are in milliseconds.

| Attribute | Data Type | Description |
| --------- | :-------: | ----------- |
| `TRACKER_TARGET` | String | Which player or library is the tracker attached to. |
| `STREAM_ID` | String | UUID that identifies a specific stream playback. It's generated when `STREAM_LOAD` happens and is different every time, even if the stream source is the same. |
| `PLAYBACK_ID` | String | Is similar to `STREAM_ID`, but it's generated every time there is an `STREAM_LOAD` or a `MEDIA_REQUEST` and recalculated when there is an `END`, `STOP` or `NEXT`. |
| `SENDER_ID` | String | Identifier of the tracker that generated the event. It uniquely identifies a tracker within an instrument. |
| `COUNT_ERRORS` | Integer | Numbee of `ERROR` events sent. |
| `COUNT_STARTS` | Integer | Number of `START` events sent. That is, the number of streams that have started. |
| `ACCUM_PAUSE_TIME` | Integer | Accumulated time during pause blocks (`PAUSE_BEGIN` / `PAUSE_FINISH`). |
| `ACCUM_BUFFER_TIME` | Integer | Accumulated time during buffering blocks (`BUFFER_BEGIN` / `BUFFER_FINISH`). |
| `ACCUM_SEEK_TIME` | Integer | Accumulated time during seeking blocks (`SEEK_BEGIN` / `SEEK_FINISH`). |
| `ACCUM_PLAY_TIME` | Integer | Accumulated time during playback, not counting ad, pause, buffering or seeking blocks. |
| `DELTA_PLAY_TIME` | Integer | Time playing since last event. |
| `IN_PAUSE_BLOCK` | Boolean | Currently within a pause block. |
| `IN_SEEK_BLOCK` | Boolean | Currently within a seeking block. |
| `IN_BUFFER_BLOCK` | Boolean | Currently within a buffering block. |
| `IN_PLAYBACK_BLOCK` | Boolean | Curently playing. |
| `ERROR_DESCRIPTION` | String | When an `ERROR` happens, description of that error. |
| `POSITION` | Integer | Current playback position in milliseconds. |
| `DURATION` | Integer | Stream duration in milliseconds. |
| `RESOLUTION_HEIGHT` | Integer | Stream vertical resolution. |
| `RESOLUTION_WIDTH` | Integer | Stream horizontal resolution. |
| `IS_MUTED` | Boolean | Playback muted. |
| `VOLUME` | Integer | Volume, from 0 to 100. |
| `FPS` | Float | Frames per second. |
| `SOURCE` | String | Stream source, usually a URL. |
| `BITRATE` | Integer | Stream bitrate in bits per second. |
| `LANGUAGE` | String | Stream language. |
| `SUBTITLES` | String | Stream subtitles language. |
| `TITLE` | String | Stream title. |
| `IS_ADS_TRACKER` | Boolean | It is an ads tracker or not. |
| `COUNT_ADS` | Integer | MNumber of ads played. |
| `IN_AD_BREAK_BLOCK` | Boolean | Currently within an ad break block. |
| `IN_AD_BLOCK` | Boolean | Currently playing an ad. |
| `AD_POSITION` | Integer | Ad playback position in milliseconds. |
| `AD_DURATION` | Integer | Ad duration in milliseconds. |
| `AD_BUFFERED_TIME` | Integr | Amount of Ad stream buffered time. |
| `AD_VOLUME` | Integer | Ad volume, from 0 to 100. |
| `AD_ROLL` | String | Ad position within the main stream (pre, mid, post). |
| `AD_DESCRIPTION` | String | Ad description. |
| `AD_ID` | String | Ad identifier. |
| `AD_TITLE` | String | Ad title. |
| `AD_ADVERTISER_NAME` | String | Advertiser name. |
| `AD_CREATIVE_ID` | String | Creative identifier. |
| `AD_BITRATE` | Integer | Ad bitrate in bits per second. |
| `AD_RESOLUTION_HEIGHT` | Integer | Ad vertical resolution. |
| `AD_RESOLUTION_WIDTH` | Integer | Ad horizontal resolution. |
| `AD_SYSTEM` | String | Ad system. |

Not all attributes are always present in all trackers. Some information may not be available in certain players.

#### Metrics

Metrics represent a numerical value that varies over time. OpenAVT supports two types of metrics: Gauge and Counter.

**Counter** measures the number of occurrences.<br>
**Gauge** represents a value that can increase or decrease.

For OpenAVT these types are purely semantical, they have no implications in how the system behaves. But some backends support this types and it has implications in how metrics are stored and queried.

| Metric | Type | Description |
| ------ | :--: | ----------- |
| `START_TIME` | Gauge | The time that takes a stream to start playing since it is requested until the first frame is shown. |
| `NUM_PLAYS` | Counter | Number of plays. |
| `REBUFFER_TIME` | Gauge | Time of rebuffering, that is the time buffering after the initial load. |
| `NUM_REBUFFERS` | Counter | Number of rebuffering events. |
| `PLAY_TIME` | Gauge | Time playing. |
| `NUM_REQUESTS` | Counter | Number of stream requests. |
| `NUM_LOADS` | Counter | Number of stream loads. |
| `NUM_ENDS` | Counter | Number of stream ends. |

#### KPIs

The most common indicators for audio and video telemetry are the following.
<!--
TODO: explain how to calculate them using the OpenAVT data model.

In this section we are going to expose general terms of how to calculate the most common audio-video KPIs using the OpenAVT data model. But not the exact practice of KPI calculation, because this is something that depends on the platform where our data is recorded. Is totally different a query made for InfluxDB than a query for New Relic.
-->

**Start Time**

Time elapsed since the stream starts loading until it starts playing.

**Playbacks**

Number of playbacks started during a certain period of time. Also the number of concurrent playbacks at a certain moment.

**Aborted Before Video Start**

The proportion (or number) of streams that started loading but never started playing.

**Rebuffering**

Total time spend in buffering blocks that are not the initial stream loading. And also the number of rebuffering blocks.

**Errors**

The proportion of playbacks that had en error. Also the proportion of initial errors (errors that happen after the media starts or right after it) and mid-stream errors.

<!--
## 6. Advanced Topics

#### Custom Instrument Elements

OpenAVT provides a set of trackers, hubs, metricalcs and backends, that cover a wide range os possibilities, but not all. For this reason the most inetresting capability it offers is its flexibility to accept custom implementations of these elements.

TODO: explain how to create custom stuff.

#### Custom Events

#### Custom Attributes

#### Custom Metrics

#### Custom Trackers

#### Custom Hubs

#### Custom Metricalcs

#### Custom Backends

#### Custom Buffers
-->

<a name="examp"></a>
## 6. Examples

Inside the `Examples` folder you will find multiple usage examples. To run them execute `pod install` from each example directory.

#### ExampleAVPlayer

Shows how to use the AVPlayer tracker.

#### ExampleAVPlayer+IMA

Shows how to use the AVPlayer tracker and the Google IMA ads tracker.

#### ExamplePlayer-ObjC

Simple example using AVPlayer tracker in Objective-C.

<a name="doc"></a>
## 7. Documentation

All classes and methods are documented with annotations. To generate the docs in HTML or Markdown you can use [swift-doc](https://github.com/SwiftDocOrg/swift-doc), like this:

```bash
$ swift doc generate Sources/ --module-name OpenAVT --format html -o docs
$ cd docs
$ python -m SimpleHTTPServer 8000
```

And then open [http://localhost:8000](http://localhost:8000) with your preferred browser.

<a name="auth"></a>
## 8. Author

Andreu Santarén Llop (asllop)<br>
andreu.santaren at gmail .com

<a name="lice"></a>
## 9. License

OpenAVT-iOS is available under the MIT license. See the LICENSE file for more info.
