require "./stoppable_event"

# Base `class` for all event objects.
#
# This event does not contain any event data and
# can be used by events that do not require any state.
#
# Can be inherited from to include information about the event.
#
# ```
# # Define a custom event
# class ExceptionEvent < AED::Event
#   getter exception : Exception
#
#   def initialize(@exception : Exception); end
# end
#
# # Using Event on its own
# dispatcher.dispatch AED::Event.new
#
# # Dispatch a custom event
# exception = ArgumentError.new "Value cannot be negative"
# dispatcher.dispatch ExceptionEvent.new exception
# ```
class Athena::EventDispatcher::Event
  include Athena::EventDispatcher::StoppableEvent
end
