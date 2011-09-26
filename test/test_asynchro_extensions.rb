require 'helper'

class TestAsynchroExtensions < Test::Unit::TestCase
  include Asynchro::Extensions

  def test_async_chain
    chain = nil
    
    async_chain do |_chain|
      chain = _chain
    end
    
    assert_equal Asynchro::Tracker, chain.class
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
