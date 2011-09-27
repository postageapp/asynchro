require 'helper'

class TestAsynchroTracker < Test::Unit::TestCase
  def test_defaults
    finished = false
    
    tracker = Asynchro::Tracker.new do |tracker|
      tracker.finish do
        finished = true
      end
    end
    
    assert_equal true, finished
    assert_equal true, tracker.finished?
  end
  
  def test_simple_tracker
    count = 0
    
    Asynchro::Tracker.new do |tracker|
      tracker.perform do |done|
        tracker.perform do |done|
          count += 2
          done.call
        end
        
        count += 1
        done.call
      end
      
      tracker.perform(4) do |done|
        4.times do
          count += 1
          done.call
        end
      end
      
      tracker.finish do
        success = true
      end
    end
    
    assert_eventually(5) do
      count == 7
    end
  end
end
