require 'helper'

class TestAsynchroExtensions < Test::Unit::TestCase
  include Asynchro::Extensions

  def test_async_tracker_implicit
    tracker = nil
    
    async_tracker do
      tracker = self
    end
    
    assert_equal Asynchro::Tracker, tracker.class
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
