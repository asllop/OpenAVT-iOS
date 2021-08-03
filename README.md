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

### 4.1 Custom Models

Creating custom models we can extend the data model, adding information that is useful for our specific use case and is not directly covered by OpenAVT.

#### 4.1.1 Custom Actions

Actions are instances of the class `OAVTAction`, and generatic a custom action is as easy as creating a new instance, providing the action name in the constructor:

```Swift
let myAction = OAVTAction(name: "CustomAction")
```

> By convention, action names are in upper camel case.

Now we can use it normally as any other action, for examplem, on an `emit`:

```Swift
instrument.emit(action: myAction, trackerId: trackerId)
```

#### 4.1.2 Custom Attributes

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

#### 4.1.3 Custom Metrics

Metrics are instances of the class `OAVTMetric`, and we build custom metrics by creating new instances of the class, providing the metric name, type and value in the constructor:

```Swift
let myMetric = OAVTMetric(name: "CustomMetric", type: .Gauge, value: 10.1)
```

> By convention, metric names are in upper camel case, like action names.

### 4.2 Custom Components

Components are objects that are part of an instrument, and conform to one of the derived protocols of `OAVTComponentProtocol`. In OpenAVT there are four types of components: Trackers, Hubs, Metricalcs and Backends.

Instruments allow hot-plugging of components, by using the lifecycle methods defined in the `OAVTComponentProtocol`. With `OAVTInstrument.addTracker(...)` and `OAVTInstrument.removeTracker(...)` we can add and remove tracker, and with `OAVTInstrument.setHub(...)`, `OAVTInstrument.setMetrical(...)` and `OAVTInstrument.setBackend(...)` we can set and overwrite hubs, metricals and backends. When this happens, the instrument calls `OAVTComponentProtocol.endOfService()` on the removed component. After any change on the instrument is made, we must call `OAVTInstrument.ready()`, that will call `OAVTComponentProtocol.ready()` on each component.

#### 4.2.1 Custom Trackers

A tracker is the element that knows about specific players, reading properties, registering observers, etc. In OpenAVT a tracker is a class that conforms to the `OAVTTrackerProtocol`, that in turn extends the `OAVTComponentProtocol`. So, the simplest possible tracker will look like:

```Swift
class DummyTracker: OAVTTrackerProtocol {
    private var state = OAVTState()
    
    func initEvent(event: OAVTEvent) -> OAVTEvent? {
        // Called when an emit(...) happens. It receives the event and must return an event or nil.
        // If an event is returned, it will be passed to the Hub.
        return event
    }
    
    func getState() -> OAVTState {
        // Return the state object
        return self.state
    }
    
    // Tracker ID, set by the instrument when the tracker is created.
    var trackerId: Int?
    
    func instrumentReady(instrument: OAVTInstrument) {
        // Called when ready() is called on the instrument.
    }
    
    func endOfService() {
        // Called when the tracker is removed from the instrument or when shutdown() is called.
    }
}
```

This tracker does almost nothing, just bypass the events received. But we could improve it a bit, let's say we want to send an event when the instrument is ready:

```Swift
    // Note that this must be a weak reference, otherwise we will have a retain cycle, because the instrument owns a reference to the tracker.
    private weak var instrument: OAVTInstrument?

    ...

    func instrumentReady(instrument: OAVTInstrument) {
        if self.instrument == nil {
            self.instrument = instrument
            self.instrument?.emit(action: OAVTAction.TrackerInit, tracker: self)
        }
    }
```

And now maybe we want to set a custom attribute to that event, but only that, no other one:

```Swift
    func initEvent(event: OAVTEvent) -> OAVTEvent? {
        if event.getAction() == OAVTAction.TrackerInit {
            event.setAttribute(key: OAVTAttribute(name: "myCustomAttr"), value: 1000)
        }
        return event
    }
```

Any event generated calling `emit` will pass thought this method (if the tracker argument of `emit` points to this tracker). Most events will be generated from within the tracker, when something happens in the player (a stream starts, the user pauses the playback, etc), but we can also call `emit` from any other place.

Generally, `instrumentReady` is used to do initializations, like registering observers in the player, set up states, send starting events, etc. And `endOfService` is used to undo all this, unregister observers, etc.

A tracker can also register attribute getters. An attribute getter binds a tracker method with an `OAVTAttribute`. Let's say our player reports the current playback position, and we want to include this attribute on every event. OpenAVT offers a pre-defined attribute to report this information: `OAVTAttribute.position`. We can define a method in our tracker that returns that position:

```Swift
    func getPosition() -> Int? {
        let p = ... //do whatever with the supported player to get the position.
        return p
    }
```

> By convention, times are reported as integers in milliseconds.

Now we need to bind this method to the attribute:

```Swift
    func instrumentReady(instrument: OAVTInstrument) {
        ...
        
        self.instrument?.registerGetter(attribute: OAVTAttribute.position, getter: self.getPosition, tracker: self)
    }
```

And finally, apply the attribute getter to every event we receive:

```Swift
    func initEvent(event: OAVTEvent) -> OAVTEvent? {
        ...
        
        self.instrument?.useGetter(attribute: OAVTAttribute.position, event: event, tracker: self)
        
        return event
    }
```

But, why all this complexity, when it would be much easier to just call the `getPosition` method, and then set the attribute using `OAVTEvent.setAttribute`?

Certainly we could do that and it would work. But by registering attribute getters, any element outside the tracker, for example a Hub, can query for a specific attribute value (using `OAVTInstrument.callGetter(...)`), doesn't matter the class and the interface. And if the  queried getter is not defined, it will just return nil and no attribute will be created.

#### 4.2.2 Custom Hubs

A hub is the element that contains the bussiness logic. It receives events from the tracker and according to the type, state, and other conditions, it decides what to do. It can also act over other components, for example updating trackers state. In OpenAVT a hub is a class that conforms to the `OAVTHubProtocol`, that in turn extends the `OAVTComponentProtocol`. A simple hub could look like:

```Swift
class DummyHub: OAVTHubProtocol {
    func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent? {
        // Called with the result of tracker's initEvent. It receives the event and must return an event or nil.
        // If an event is returned, it will be sent to the Metricalc and the Backend.
        return event
    }
    
    func instrumentReady(instrument: OAVTInstrument) {
        // Called when ready() is called on the instrument.
    }
    
    func endOfService() {
        // Called when the tracker is removed from the instrument or when shutdown() is called.
    }
}
```

The main method for a hub is the `processEvent`, that is called with the event returned by a tracker. Along with the event, it receives the tracker that generated it.

This simple hub does nothing more than bypassing the events received, but it could implement complex logics: It could update the tracker's state depending on the received events, block an event that is not supposed to happen, add or modify attributes, start or stop timers, etc. It's up to your particular use case. In the following example we see how to handle the pause logic:

```Swift
    func processEvent(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> OAVTEvent? {
        if event.getAction() == OAVTAction.PauseBegin {
            if tracker.getState().isPaused {
                return nil
            }
            tracker.getState().isPaused = true
        }
        else if event.getAction() == OAVTAction.PauseFinish {
            if !tracker.getState().isPaused {
                return nil
            }
            tracker.getState().isPaused = false
        }
        return event
    }
```

#### 4.2.3 Custom Metricalcs

A metricalc is similar to a hub, but for metrics, it handles the business logic to generate metrics. A metricalc is a class that conforms to the `OAVTMetricalcProtocol`:

```Swift
class DummyMetricalc: OAVTMetricalcProtocol {
    func processMetric(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> [OAVTMetric] {
        // Called with the result of hub's processEvent. It receives the event and returns an array of metrics.
        // If any metric is returned, it will be sent to the Backend.
        return []
    }
    
    func instrumentReady(instrument: OAVTInstrument) {
        // Called when ready() is called on the instrument.
    }
    
    func endOfService() {
        // Called when the tracker is removed from the instrument or when shutdown() is called.
    }
}
```

This metricalc does nothing, it generates no metrics. Let's imagine we want to generate a metric that measures the time between quality change events. We could do something like:

```Swift
    private var tsOfLastEvent: TimeInterval = 0.0
    
    func processMetric(event: OAVTEvent, tracker: OAVTTrackerProtocol) -> [OAVTMetric] {
        if event.getAction() == OAVTAction.QualityChangeUp || event.getAction() == OAVTAction.QualityChangeDown {
            if self.tsOfLastEvent > 0.0 {
                let metric = OAVTMetric(name: "TimeBetweenQualityChanges", type: .Gauge, value: NSDate().timeIntervalSince1970 - self.tsOfLastEvent)
                self.tsOfLastEvent = NSDate().timeIntervalSince1970
                return [metric]
            }
        }
        
        return []
    }
```

#### 4.2.4 Custom Backends

The final stop for an event is the backend, that is a class conforming to the `OAVTBackendProtocol`. Is the backend's duty to store or redirect data to a database, server, filesystem, etc.

```Swift
class DummyBackend: OAVTBackendProtocol {
    func sendEvent(event: OAVTEvent) {
        // Called with the result of hub's processEvent.
    }
    
    func sendMetric(metric: OAVTMetric) {
        // Called with the results of metricalc's processMetric.
    }
    
    func instrumentReady(instrument: OAVTInstrument) {
        // Called when ready() is called on the instrument.
    }
    
    func endOfService() {
        // Called when the tracker is removed from the instrument or when shutdown() is called.
    }
}
```

The method `sendMetric` is called once with each metric returned by metricalc's `processMetric`.

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
