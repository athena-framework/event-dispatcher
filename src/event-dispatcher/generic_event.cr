require "./event"

# A convenience `Event` type that provides a stateful, reusable `Event` object.
#
# Can be used to wrap other `Event` types, scalar values, etc.  Provides a singular interface to interact with.
#
# TODO: Add example
class Athena::EventDispatcher::GenericEvent(T) < Athena::EventDispatcher::Event
  # The possible values that can be stored in `Athena::EventDispatcher::GenericEvent#arguments`.
  alias ArgumentType = Hash(String, String | Int::Signed | Float32 | Float64 | Bool | Nil)

  # The subject of the event.  Could be an `Event` instance or anything else.
  getter subject : T

  # Arguments to store in the `self`.
  getter arguments : ArgumentType

  def initialize(@subject : T, @arguments : ArgumentType = ArgumentType.new); end
end
