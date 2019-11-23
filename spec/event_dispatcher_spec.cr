require "./spec_helper"

class TestEvent < AED::Event
  property value : Int32 = 0
end

class FakeEvent < AED::Event
end

struct TestListener < AED::Listener
  @[AED::EventHandler]
  def listen(event : TestEvent, dispatcher : AED::EventDispatcherInterface) : Nil
    event.value += 1
  end

  @[AED::EventHandler]
  def single_arg(event : TestEvent, dispatcher : AED::EventDispatcherInterface) : Nil
    event.value += 2
  end
end

describe AED::EventDispatcher do
  describe "#add_listener" do
    it "should add the provided listener" do
      dispatcher = AED::EventDispatcher.new

      dispatcher.has_listeners?(FakeEvent).should be_false

      handler = AED.create_handler(FakeEvent) { }

      dispatcher.add_listener FakeEvent, handler

      dispatcher.has_listeners?(FakeEvent).should be_true
    end
  end

  describe "#dispatch" do
    it "should pass the event to all listeners" do
      dispatcher = AED::EventDispatcher.new

      event = TestEvent.new

      dispatcher.dispatch event

      event.value.should eq 3
    end
  end

  describe "#get_listeners" do
    describe :event do
      describe "that has listeners" do
        it "should return an array of procs" do
          dispatcher = AED::EventDispatcher.new

          listeners = dispatcher.get_listeners(TestEvent)

          event = TestEvent.new

          listeners.size.should eq 2
          listeners.first.call(event, dispatcher)

          event.value.should eq 1
        end
      end

      describe "that doesn't have any listeners" do
        it "should return an empty array" do
          AED::EventDispatcher.new.get_listeners(FakeEvent).should be_empty
        end
      end
    end

    describe :no_event do
      it "should return an array of procs" do
        AED::EventDispatcher.new.get_listeners.size.should eq 2
      end
    end
  end

  describe "#has_listeners" do
    describe :event do
      describe "and there are some listening" do
        it "should return true" do
          AED::EventDispatcher.new.has_listeners?(TestEvent).should be_true
        end
      end

      describe "and there are none listening" do
        it "should return false" do
          AED::EventDispatcher.new.has_listeners?(FakeEvent).should be_false
        end
      end
    end

    describe :no_event do
      describe "and there are some listening" do
        it "should return true" do
          AED::EventDispatcher.new.has_listeners?.should be_true
        end
      end
    end
  end

  pending "#get_listener_priority" do
  end

  describe "#remove_listener" do
    it "should remove the listener" do
      dispatcher = AED::EventDispatcher.new

      dispatcher.has_listeners?(TestEvent).should be_true

      dispatcher.remove_listener TestEvent, TestListener

      dispatcher.has_listeners?(TestEvent).should be_false
    end
  end
end
