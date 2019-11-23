require "./event-dispatcher/event_dispatcher"

# Convenience alias to make referencing `Athena::EventDispatcher` types easier.
alias AED = Athena::EventDispatcher

# A [Mediator](https://en.wikipedia.org/wiki/Mediator_pattern) and [Observer](https://en.wikipedia.org/wiki/Observer_pattern)
# pattern event library.
#
# `Athena::EventDispatcher` or, `AED` for short, allows registering `EventHandler`s on `Listener` structs (observers) that will be executed
# when an `Event` is dispatched via the `EventDispatcher` (mediator).
#
# All events are registered with and dispatched  via the `EventDispatcher` at compile time.  While the recommended usage involves using
# listener structs, it is also possible to add/remove event handlers dynamically at runtime.
#
# An event is nothing more than a `class` that, optionally, contains stateful information about the event.  For example a `HttpOnRequest` event would
# contain a reference to the `HTTP::Request` object so that the listeners have access to request data.  Similarly, a `HttpOnResponse` event
# would contain a reference to the `HTTP::Server::Response` object so that the response body/headers/status can be mutated by the listeners.
#
# Since events and listeners are registered at compile time, listeners can be added to a project seamlessly without updating any configuration, or having
# to instantiate a `HTTP::Handler` object and add it to an array for example.  The main benefit of this is that an external shard that defines a listener could
# be installed and would inherently be picked up and used by `Athena::EventDispatcher`; thus making an application easily extendable.
#
#
#
# ### Example
# ```
#  # New up a `EventDispatcher`.
#  dispatcher =
# ```
module Athena::EventDispatcher
  VERSION = "0.1.0"

  # Creates a listener for the provided *event* with the provided *handler*.  class ExceptionEvent < AED::Event
  #
  # The macro *handler* block implicitly yields `event` and `dispatcher`.
  #
  # ```
  # handler = AED.create_handler(SampleEvent) do
  #   # Do something with the event.
  #   event.some_method
  #
  #   # A reference to the `Athena::EventDispatcher::EventDispatcherInterface` is also provided.
  #   dispatcher.dispatch FakeEvent.new
  #
  #   # The handler *MUST* return `nil`.
  #   nil
  # end
  #
  # NOTE: The *handler* block must return `nil`.
  macro create_handler(event, &handler)
    ->(event : AED::Event, dispatcher : AED::EventDispatcherInterface) do
      ->(event : {{event}}, dispatcher : AED::EventDispatcherInterface) {{handler}}.call event.as({{event}}), dispatcher
    end
  end
end
