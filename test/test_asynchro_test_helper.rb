require 'helper'

class TestAsynchroTestHelper < Test::Unit::TestCase
  def test_eventmachine
    ran = false
    
    eventmachine do
      assert EventMachine.reactor_running?
      assert !EventMachine.reactor_thread?
      
      EventMachine.add_timer(1) do
        ran = true
      end
      
      while (!ran)
        # Spin-lock here while waiting for flag to be set in reactor thread
      end
    end
    
    assert_equal true, ran
  end
end
