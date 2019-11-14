# Base class of an event dispatcher.  Defines how dispatchers should be implemented.
abstract class Athena::EventDispatcher::EventDispatcherInterface
  # Adds the provided *handler* proc as a listener for *event*.
  abstract def add_listener(event : Event.class, handler : Proc(Event, EventDispatcherInterface, Nil)) : Nil

  # Dispatches *event* to all listeners registered on `self` that are listening on that event.
  abstract def dispatch(event : Event) : Nil

  # Returns `true` if there are any listeners listening on the provided *event*.
  # If no *event* is provided, returns `true` if there are *ANY* listeners registered on `self`.
  abstract def has_listeners(event : Event.class | Nil) : Bool

  # Removes the provided *event* from the provided *listener*.
  abstract def remove_listener(event : Event.class, listener : Listener.class) : Nil
end
