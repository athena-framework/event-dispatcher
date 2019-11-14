require "./stoppable_event"

# Base struct for all event objects.
#
# This event does not contain any event data and
# can be used by events that do not require any state.
#
# Can be inherited from to include information about the event.
#
# TODO: Add example
abstract class Athena::EventDispatcher::Event
  include Athena::EventDispatcher::StoppableEvent
end
