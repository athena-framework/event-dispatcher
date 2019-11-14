# Base struct for event listeners.
#
# Listeners are registered by inheriting from this class.
# An event can be handled by annotating an instance method with `AED::EventHandler`.
# See the annotation definition for more details.
abstract struct Athena::EventDispatcher::Listener; end
