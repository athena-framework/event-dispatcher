# An `Event` whose processing may be interrupted when the event has been handled.
#
# `EventDispatcherInterface` implementations MUST check to determine if an Event
# is marked as stopped after each listener is called.  If it is then it should
# return immediately without calling any further `Listener`.
module Athena::EventDispatcher::StoppableEvent
  @propatation_stopped : Bool = false

  # If future event listeners should be executed.
  def propagate? : Bool
    !@propatation_stopped
  end

  # Prevent future listeners from executing once
  # any listener calls `#stop_propagation` on `self`.
  def stop_propagation : Nil
    @propatation_stopped = true
  end
end
