# Base class of an event dispatcher.  Defines how dispatchers should be implemented.
abstract class Athena::EventDispatcher::EventDispatcherInterface
  alias EventListenerType = Listener | Proc(Event, EventDispatcherInterface, Nil)

  # Wraps an `EventListenerType` in order to keep track of its `priority`.
  record EventListener, listener : EventListenerType, priority : Int32 = 0 do
    delegate :call, :==, to: @listener
  end

  # Adds the provided *listener* as a listener for *event*, optionally with the provided *priority*.
  abstract def add_listener(event : Event.class, listener : EventListenerType, priority : Int32) : Nil

  # Dispatches *event* to all listeners registered on `self` that are listening on that event.
  abstract def dispatch(event : Event) : Nil

  # Returns the listeners listeneing on the provided *event*.
  # If no *event* is provided, returns all listeners.
  abstract def listeners(event : Event.class | Nil) : Array(EventListener)

  # Returns the *listener* priority for the provided *event*.  Returns `nil` if no listeners are listening on the provided *event* or
  # if *listener* isn't listening on *event*.
  abstract def listener_priority(event : Event.class, listener : Listener.class) : Int32?

  # Returns `true` if there are any listeners listening on the provided *event*.
  # If no *event* is provided, returns `true` if there are *ANY* listeners registered on `self`.
  abstract def has_listeners?(event : Event.class | Nil) : Bool

  # Removes the provided *event* from the provided *listener*.
  abstract def remove_listener(event : Event.class, listener : Listener.class) : Nil

  # :ditto:
  abstract def remove_listener(event : Event.class, listener : EventListenerType) : Nil
end
