require 'helper'

class TestAsynchroExtensions < Test::Unit::TestCase
  include Asynchro::Extensions

  def test_async_tracker
    @context = nil
    finished = false
    
    async_tracker do |tracker|
      tracker.perform do |callback|
        @context = self
        callback.call
      end
      
      tracker.finish do
        finished = true
      end
    end
    
    assert_eventually(1) do
      assert_equal TestAsynchroExtensions, @context.class
      assert_equal true, finished
    end
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
