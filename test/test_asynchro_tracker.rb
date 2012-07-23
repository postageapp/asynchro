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
    success = 0
    
    Asynchro::Tracker.new do |tracker|
      tracker.perform(3) do |done1|
        tracker.perform(2) do |done2|
          count += 10
          done2.call
        end
        
        count += 1
        done1.call
      end
      
      trigger = nil
      
      tracker.perform(8) do |done|
        count += 100
        trigger = done
      end
      
      tracker.perform(4) do |done|
        count += 1000
        trigger.call
        trigger.call
        done.call
      end
      
      tracker.finish do
        success += 1
      end

      tracker.finish do
        success += 100
      end
    end
    
    assert_equal 4863, count
    assert_equal 101, success
  end
  
  def test_repetition
    test_cycle = 1000
    count = 0

    Asynchro::Tracker.new do |tracker1|
      tracker1.perform(test_cycle) do |done1|
        Asynchro::Tracker.new do |tracker2|
          tracker2.perform(test_cycle) do |done2|
            count += 1
            done2.call
          end
          
          tracker2.finish do
            done1.call
          end
        end
      end
    end
    
    assert_equal test_cycle * test_cycle, count
  end
end
