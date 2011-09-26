require 'helper'

class TestAsynchroTracker < Test::Unit::TestCase
  def test_async_chain_explicit
    count = 0
    
    Asynchro::Tracker.new do |chain|
      chain.perform do |done|
        chain.perform do |done|
          count += 2
          done.call
        end
        
        count += 1
        done.call
      end
      
      chain.perform(4) do |done|
        4.times do
          count += 1
          done.call
        end
      end
      
      chain.finish do
        success = true
      end
    end
    
    assert_eventually(5) do
      count == 7
    end
  end

  def test_async_chain_implicit
    success = false
    
    Asynchro::Tracker.new do
      perform do |done|
        done.call
      end
      
      finish do
        success = true
      end
    end
    
    assert_eventually(5) do
      success
    end
  end
end
