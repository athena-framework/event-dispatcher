require "./event-dispatcher/event_dispatcher"

# Convenience alias to make referencing `Athena::EventDispatcher` types easier.
alias AED = Athena::EventDispatcher

# A [Mediator](https://en.wikipedia.org/wiki/Mediator_pattern) and [Observer](https://en.wikipedia.org/wiki/Observer_pattern)
# pattern event library.
#
# `Athena::EventDispatcher` or, `AED` for short, allows defining instance methods on `Listener` structs (observers) that will be executed
# when an `Event` is dispatched via the `EventDispatcher` (mediator).
#
# All events are registered with and dispatched  via the `EventDispatcher` at compile time.  While the recommended usage involves using
# listener structs, it is also possible to add/remove event handlers dynamically at runtime.  The `EventDispatcher` has two constructors;
# one that supports manual or DI initialization, while the other auto registers listeners at compile time via macros.
#
# An event is nothing more than a `class` that, optionally, contains stateful information about the event.  For example a `HttpOnRequest` event would
# contain a reference to the `HTTP::Request` object so that the listeners have access to request data.  Similarly, a `HttpOnResponse` event
# would contain a reference to the `HTTP::Server::Response` object so that the response body/headers/status can be mutated by the listeners.
#
# Since events and listeners are registered at compile time (via macros or DI), listeners can be added to a project seamlessly without updating any configuration, or having
# to instantiate a `HTTP::Handler` object and add it to an array for example.  The main benefit of this is that an external shard that defines a listener could
# be installed and would inherently be picked up and used by `Athena::EventDispatcher`; thus making an application easily extendable.
#
# ### Example
# ```
#  # New up a `EventDispatcher`, using `EventDispatcher#new`.
#  dispatcher =
# ```
module Athena::EventDispatcher
  VERSION = "0.1.0"

  # The possible types an event listener can be.  `AED::Listener` instances use `#call`
  # in order to keep a common interface with the `Proc` based listeners.
  alias EventListenerType = Listener | Proc(Event, EventDispatcherInterface, Nil)

  # The mapping of the `AED::Events` and the priority a `AED::Listener` is listening on.
  #
  # See `AED::Listener`.
  alias SubscribedEvents = Hash(AED::Event.class, Int32)

  # Wraps an `EventListenerType` in order to keep track of its `priority`.
  struct EventListener
    # :nodoc:
    delegate :call, :==, to: @listener

    # The wrapped `EventListenerType` instance.
    getter listener : EventListenerType

    # The priority of the `EventListenerType` instance.
    #
    # The higher the `priority` the sooner `listener` will be executed.
    getter priority : Int32 = 0

    def initialize(@listener : EventListenerType, @priority : Int32 = 0); end
  end

  # Creates a listener for the provided *event*.  The macros block is used as the listener.
  #
  # The macro *handler* block implicitly yields `event` and `dispatcher`.
  #
  # ```
  # listener = AED.create_listener(SampleEvent) do
  #   # Do something with the event.
  #   event.some_method
  #
  #   # A reference to the `AED::EventDispatcherInterface` is also provided.
  #   dispatcher.dispatch FakeEvent.new
  # end
  # ```
  macro create_listener(event, &)
    Proc(AED::Event, AED::EventDispatcherInterface, Nil).new do |event, dispatcher|
      Proc({{event.id}}, AED::EventDispatcherInterface, Nil).new do |event, dispatcher|
        {{yield}}
      end.call event.as({{event}}), dispatcher
    end
  end
end
