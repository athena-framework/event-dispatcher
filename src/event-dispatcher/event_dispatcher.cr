require "./event_dispatcher_interface"
require "./event"
require "./listener"

class Athena::EventDispatcher::EventDispatcher < Athena::EventDispatcher::EventDispatcherInterface
  # :nodoc:
  # Used internally to store event listener handlers and metadata related to it.
  private record Callable, listener : Listener.class, handler : Proc(Event, EventDispatcherInterface, Nil), priority : Int32 = 0 do
    delegate :call, to: @handler
  end

  @events : Hash(Event.class, Array(Callable))

  # Instantiates `self`, building out the hash of events at compile time.
  def initialize
    # Work around for https://github.com/crystal-lang/crystal/issues/7975.
    {{@type}}

    {% begin %}
      # Initialize the event_hash, with a default size of the number of event subclasses
      @events = Hash(Event.class, Array(Callable)).new {{Event.all_subclasses.size}} { raise "Bug: Accessed" }

      # Iterate over event classes to "register" them with the events hash
      {% for event in Event.all_subclasses %}
        {% unless event.abstract? %}
          # Initialize each event to an empty array with a default size of the number of total listeners
          # TODO: Remove gsub once crystal-lang/crystal#8458 is released
          @events[{{event.name.gsub(/\(.*\)/, "")}}] = Array(Callable).new {{Listener.all_subclasses.size}}
        {% end %}
      {% end %}

      # Iterate over each listener class
      {% for listener, idx in Listener.subclasses %}

        # Instantiate the listener class
        %listener{idx} = {{listener.id}}.new.as({{listener.id}})

        # Iterate over the event handlers of the listener
        {% for handler in listener.methods.select { |m| m.annotation(EventHandler) } %}
          {% raise "Event handler #{listener}##{handler.name} must only have one argument" if handler.args.size > 2 %}
          {% event = handler.args.first.restriction %}
          {% raise "Event handler #{listener}##{handler.name}'s argument must be restricted to an `Event` instance." if !event || !(event.resolve <= Event) %}

          # Add each event handler action to the event_hash.  Events are keyed by the handler's argument.
          @events[{{event}}] << Callable.new listener: {{listener.id}}, handler: ->(event : Event, dispatcher : EventDispatcherInterface) do
            %handler = ->%listener{idx}.{{handler.name.id}}({{event}}, EventDispatcherInterface)
            %handler.call event.as({{event}}), dispatcher
          end
        {% end %}
      {% end %}
    {% end %}
  end

  # :inherit:
  def add_listener(event : Event.class, handler : Proc(Event, EventDispatcherInterface, Nil)) : Nil
    @events[event] << Callable.new listener: Listener, handler: handler
  end

  # :inherit:
  def dispatch(event : Event) : Nil
    @events[event.class].each &.call event, self
  end

  # :inherit:
  def has_listeners(event : Event.class | Nil = nil) : Bool
    return !@events[event].empty? if event

    @events.values.any? { |listener_arr| !listener_arr.empty? }
  end

  # :inherit:
  def remove_listener(event : Event.class, listener : Listener.class) : Nil
    @events[event].reject! &.listener.==(listener)
  end
end
