# OpenAVT-iOS

[![License](https://img.shields.io/github/license/asllop/OpenAVT-iOS)](https://github.com/asllop/OpenAVT-iOS)

1. [ Introduction ](#intro)
2. [ Installation ](#install)
3. [ Usage ](#usage)
4. [ Custom Elements ](#custom)
5. [ Examples ](#examp)
6. [ Documentation ](#doc)
7. [ Author ](#auth)
8. [ License ](#lice)

<a name="intro"></a>
## 1. Introduction

The Open Audio-Video Telemetry is a set of tools for performance monitoring in multimedia applications. The objectives are similar to those of the OpenTelemetry project, but specifically for sensing data from audio and video players. OpenAVT can be configured to generate Events, Metrics, or a combination of both.

<a name="install"></a>
## 2. Installation

To install OpenAVT-iOS, simply add the following line to your Podfile:

```ruby
pod 'OpenAVT-Core', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

Besides the Core, the following modules are available:

#### 2.1 AVPlayer Tracker

Tracker for the AVPlayer video and audio player.

```ruby
pod 'OpenAVT-AVPlayer', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### 2.2 Google IMA Tracker

Tracker for the Google IMA ads library.

```ruby
pod 'OpenAVT-IMA', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### 2.3 Graphite Backend

Backend for the Graphite metrics database.

```ruby
pod 'OpenAVT-Graphite', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### 2.4 InfluxDB Backend

Backend for the InfluxDB metrics database.

```ruby
pod 'OpenAVT-InfluxDB', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

#### 2.5 New Relic Backend

Backend for the New Relic data ingestion service.

```ruby
pod 'OpenAVT-NewRelic', :git => 'https://github.com/asllop/OpenAVT-iOS'
```

<a name="usage"></a>
## 3. Usage

There are many ways to use the OpenAVT library, depending on the use case, here we will cover the most common combinations. We won't explain all the possible arguments passed to the constructors, only the essential ones. For the rest check out the [documentation](#doc).

### 3.1 Choosing a Backend

The first step is choosing the backend where the data will be sent. We currently support OOTB three different backends: Graphite, InfluxDB, and New Relic. Let's see how to init them:

#### 3.1.1 Init the Graphite Backend

```swift
let backend = OAVTBackendGraphite(host: "192.168.99.100")
```

`host` is the address of the Graphite server.

#### 3.1.2 Init the InfluxDB Backend

```swift
let backend = OAVTBackendInfluxdb(url: URL(string: "http://192.168.99.100:8086/write?db=test")!)
```

`url` is the URL of the InfluxDB server used to write data to a particular database (in this case named `test`).

#### 3.1.3 Init the New Relic Backend

```swift
let backend = OAVTBackendNewrelic()
```

The New Relic Mobile Agent must be installed and set up to use this backend.

### 3.2 Choosing a Hub

Next, we will choose a Hub. This element is used to obtain the data coming from the trackers and process it to pass the proper events to the backend. Users can implement their logic for this and use their custom hubs, but OpenAVT provides a default implementation that works for most cases.

For instruments with video tracker only, we will choose:

```swift
let hub = OAVTHubCore()
```

And for instruments with video and ads tracker:

```swift
let hub = OAVTHubCoreAds()
```

### 3.3 Choosing a Metricalc

This step is optional and only necessary if we want to generate metrics, if we only need events this section can be omitted. A Metricalc is something like a Hub but for metrics, it gets events and processes them to generate metrics. Again, users can provide custom implementation, but the OpenAVT library provides a default one:

```swift
let metricalc = OAVTMetricalcCore()
```

### 3.4 Choosing Trackers

And finally, the trackers, the piece that generates the data. Currently, OpenAVT provides two trackers: AVPlayer and Google IMA Ads. We won't cover how to set up the AVPlayer and IMA libraries, for this check out the corresponding documentation or the [examples](#examp).

#### 3.4.1 Init the AVPlayer Tracker

```swift
let tracker = OAVTTrackerAVPlayer(player: avplayer)
```

Where `player` is an instance of the AVPlayer.

#### 3.4.2 Init the IMA Tracker

```swift
let adTracker = OAVTTrackerIMA()
```

### 3.5 Creating the Instrument

Once we have all the elements, the only step left is putting everything together:

```swift
let instrument = OAVTInstrument(hub: hub, metricalc: metricalc, backend: backend)
let trackerId = instrument.addTracker(tracker)
let adTrackerId = instrument.addTracker(adTracker)
instrument.ready()
```

Here we have created a new instrument that contains all the elements, and once all are present, we called `ready()` to initialize everything, This will cause the execution of the method `OAVTComponentProtocol.instrumentReady(...)` in all trackers, hub, metricalc and backend. Now the instrument is ready to start generating data.

<a name="custom"></a>
## 4. Custom Elements

OpenAVT provides a set of elements that cover a wide range of possibilities, but not all. For this reason, the most interesting capability it offers is its flexibility to accept custom implementations of these elements.

### 4.1 Custom Actions

Actions are instances of the class `OAVTAction`, and generatic a custom action is as easy as creating a new instance, providing the action name in the constructor:

```Swift
let myAction = OAVTAction(name: "CustomAction")
```

> By convention, action names are in upper camel case.

Now we can use it normally as any other action, for examplem, on an `emit`:

```Swift
instrument.emit(action: myAction, trackerId: trackerId)
```

### 4.2 Custom Attributes

Attributes are instances of the class `OAVTAttribute`. We build a custom attribute by creating a new instance of the class, providing the name in the constructor:

```Swift
let myAttr = OAVTAttribute(name: "customAttribute")
```

> By convention, attribute names are in lower camel case.

In the previous section we saw how to create custom actions, but we left something. All actions have an associated time-since attribute. The attribute name is autogenerated based on the action name, being `timeSince` plus the action name the default. In the case of the example, it will be `timeSinceCustomAction`. But we can provide an attribute in the constructor if the default one doesn't work for us:

```Swift
let myAction = OAVTAction(name: "CustomAction", timeAttribute: OAVTAttribute(name: "myTimeSince"))
```

> You can read more on time-since attributes [here](https://github.com/asllop/OpenAVT-Docs#model), section *4.3 Attributes*.

A custom attribute can be used as any other attribute, for example, setting it on an event:

```Swift
// `event` is an instance of OAVTEvent
event.setAttribute(key: myAttr, value: "any value")
```

### 4.3 Custom Metrics

Metrics are instances of the class `OAVTMetric`, and we build custom metrics by creating new instances of the class, providing the metric name, type and value in the constructor:

```Swift
let myMetric = OAVTMetric(name: "CustomMetric", type: .Gauge, value: 10.1)
```

> By convention, metric names are in upper camel case, like action names.

<!--
TODO

### 4.4 Custom Trackers

### 4.5 Custom Hubs

### 4.6 Custom Metricalcs

### 4.7 Custom Backends

### 4.8 Custom Buffers
-->

<a name="examp"></a>
## 5. Examples

Inside the `Examples` folder, you will find multiple usage examples. To run them execute `pod install` from each example directory.

#### 5.1 ExampleAVPlayer

Shows how to use the AVPlayer tracker.

#### 5.2 ExampleAVPlayer+IMA

Shows how to use the AVPlayer tracker and the Google IMA ads tracker.

#### 5.3 ExamplePlayer-ObjC

Simple example using AVPlayer tracker in Objective-C.

<a name="doc"></a>
## 6. Documentation

**Check out the [Documentation Repository](https://github.com/asllop/OpenAVT-Docs) for general and platform-independent documentation.**

All classes and methods are documented with annotations. To generate the docs in HTML or Markdown you can use [swift-doc](https://github.com/SwiftDocOrg/swift-doc), like this:

```bash
$ swift doc generate Sources/ --module-name OpenAVT --format html -o docs
$ cd docs
$ python -m SimpleHTTPServer 8000
```

And then open [http://localhost:8000](http://localhost:8000) with your preferred browser.

<a name="auth"></a>
## 7. Author

Andreu Santarén Llop (asllop)<br>
andreu.santaren at gmail .com

<a name="lice"></a>
## 8. License

OpenAVT-iOS is available under the MIT license. See the LICENSE file for more info.
