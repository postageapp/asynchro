require 'helper'

class TestAsynchroExtensions < Test::Unit::TestCase
  include Asynchro::Extensions

  def test_async_tracker_implicit
    tracker = nil
    finished = false
    
    async_tracker do
      perform do |callback|
        tracker = self
        callback.call
      end
      
      finish do
        finished = true
      end
    end
    
    assert_equal Asynchro::Tracker, tracker.class
    assert_equal true, finished
  end

  def test_async_state_explicit
    state = nil
    
    async_state do |_state|
      state = _state
    end
    
    assert_equal Asynchro::State, state.class
  end
  
  def test_async_state_implicit
    state = nil
    
    async_state do
      state = self
    end
    
    assert_equal Asynchro::State, state.class
  end
end
