require "./event_dispatcher_interface"
require "./event"
require "./listener"

class Athena::EventDispatcher::EventDispatcher < Athena::EventDispatcher::EventDispatcherInterface
  # Mapping of `Event` types to `EventListener` listening on that event.
  @events : Hash(Event.class, Array(EventListener))

  # Keep track of which events have been sorted so that listener arrays can be sorted only when needed.
  @sorted : Set(Event.class) = Set(Event.class).new

  # Initializes `self` with the provided *listeners*.
  #
  # This overload is mainly intended for DI or to manually
  # configure the listeners that should be used.
  def initialize(listeners : Array(Listener))
    # Initialize the event_hash, with a default size of the number of event subclasses. Add one to account for `Event` itself.
    @events = Hash(Event.class, Array(EventListener)).new {{Event.all_subclasses.size + 1}} { raise "Bug: Accessed missing event type" }

    # Iterate over event classes to "register" them with the events hash
    {% for event in Event.all_subclasses %}
      {% raise "Event '#{event.name}' cannot be generic" if event.type_vars.size >= 1 %}
      {% unless event.abstract? %}
        # Initialize each event to an empty array with a default size of the number of total listeners
        @events[{{event.id}}] = Array(EventListener).new {{Listener.all_subclasses.size}}
      {% end %}
    {% end %}

    listeners.each do |listener|
      listener.class.subscribed_events.each do |event, priority|
        @events[event] << EventListener.new listener, priority
      end
    end
  end

  def self.new
    new {{AED::Listener.subclasses.map { |listener| "#{listener.id}.new".id }}}
  end

  # :inherit:
  def add_listener(event : Event.class, listener : EventListenerType, priority : Int32 = 0) : Nil
    @events[event] << EventListener.new listener, priority
  end

  # :inherit:
  def dispatch(event : Event) : Nil
    listeners(event.class).each do |listener|
      return if event.is_a?(StoppableEvent) && !event.propagate?

      listener.call event, self
    end
  end

  # :inherit:
  def listeners(event : Event.class | Nil = nil) : Array(EventListener)
    if event
      sort(event) unless @sorted.includes? event

      return @events[event]
    end

    @events.values.flatten
  end

  # :inherit:
  def listener_priority(event : Event.class, listener : Listener.class) : Int32?
    return nil unless has_listeners? event

    @events[event].find(&.listener.class.==(listener)).try &.priority
  end

  # :inherit:
  def has_listeners?(event : Event.class | Nil = nil) : Bool
    return !@events[event].empty? if event

    @events.values.any? { |listener_arr| !listener_arr.empty? }
  end

  # :inherit:
  def remove_listener(event : Event.class, listener : Listener.class) : Nil
    @events[event].reject! &.listener.class.==(listener)
  end

  # :inherit:
  def remove_listener(event : Event.class, listener : EventListenerType) : Nil
    @events[event].reject! &.==(listener)
  end

  private def sort(event : Event.class) : Nil
    @events[event].sort_by!(&.priority).reverse!
  end
end
