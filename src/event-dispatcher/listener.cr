# Base for `struct` based event listeners.
#
# Listeners are defined by inheriting from this class.
#
# An event can be listened for by defining `#call(event : AED::Event, dispatcher : AED::EventDispatcherInterface) : Nil`.
# The first argument should be typed to the specific `AED::Event` instance that the method should listen on.  Multiple methods can be defined to handle
# multiple events within the same listener.
#
# Children must also define `self.subscribed_events : AED::SubscribedEvents` that represents the events that `self`'s methods
# are listening on.  The value of the hash is the priority of the listener.  The higher the value the sooner that listener method gets executed.
#
# Children can also define initializers if external dependencies are required for handling the event.  However, `AED::EventDispatcher#new(listeners : Array(Listener))`
# must be used to register `self`, either with DI, or provided manually.
#
# ```
# struct TestListener < AED::Listener
#   def self.subscribed_events : AED::SubscribedEvents
#     AED::SubscribedEvents{
#       HttpRequestEvent => 0,
#       ExceptionEvent   => 4,
#     }
#   end
#
#   def call(event : HttpRequestEvent, dispatcher : AED::EventDispatcherInterface) : Nil
#     # Do something with the `HttpRequestEvent` and/or dispatcher
#   end
#
#   def call(event : ExceptionEvent, dispatcher : AED::EventDispatcherInterface) : Nil
#     # Do something with the `ExceptionEvent` and/or dispatcher
#   end
# end
# ```
abstract struct Athena::EventDispatcher::Listener
  # Example method for listening on a specific *event*.  Children can define multiple of these,
  # assuming each one listens on a different `AED::Event` type.
  #
  # Internally this method is used to make the compiler happy, in practice it should never get called.
  def call(event : AED::Event, dispatcher : AED::EventDispatcherInterface) : Nil; end
end
