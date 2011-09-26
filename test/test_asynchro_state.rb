require 'helper'

class TestAsynchroState < Test::Unit::TestCase
  def test_empty
    ran = false
    instance = nil
    
    Asynchro::State.new do
      ran = true
      instance = self
    end
    
    assert_eventually(5) do
      assert_equal true, ran
      assert_equal Asynchro::State, instance.class
    end
  end
  
  def test_declared_names
    state = Asynchro::State.new
    ran = [ ]
    
    state.declare(:start) do
      ran << :start
      state.run!(:state1)
    end

    state.declare(:state1) do
      ran << :state1
      state.run!(:state2)
    end

    state.declare(:state2) do
      ran << :state2
      state.run!(:state3)
    end
    
    state.declare(:state3) do
      ran << :state3
      state.finish!
    end
    
    state.run!
    
    assert_eventually(5) do
      assert_equal [ :start, :state1, :state2, :state3 ], ran
    end
  end

  def test_implicit_names
    ran = [ ]
    tester = self

    Asynchro::State.new do
      start do
        ran << :start
        state1!
      end

      state1 do
        ran << :state1
        state2!
      end

      state2 do
        ran << :state2
        state3!
      end

      state3 do
        ran << :state3
        finish!
      end
      
      finish do
        ran << :finish
      end
    end

    assert_eventually(5) do
      assert_equal [ :start, :state1, :state2, :state3, :finish ], ran
    end
  end

  def test_configurable_binding
    result = nil
    
    Asynchro::State.new do |map|
      map.start do
        result = self.example_method?
      end
    end
    
    assert_eventually(5) do
      assert_equal :yes, result
    end
  end

  def test_arbitrary_names
    state = Asynchro::State.new
    ran = [ ]
    
    state.start do
      ran << :start
      state.state1!
    end

    state.state1 do
      ran << :state1
      state.state2!
    end

    state.state2 do
      ran << :state2
      state.state3!
    end
    
    state.state3 do
      ran << :state3
      state.finish!
    end
    
    state.finish do
      ran << :finish
    end
    
    state.run!
    
    assert_eventually(5) do
      assert_equal [ :start, :state1, :state2, :state3, :finish ], ran
    end
  end
  
protected
  def example_method?
    :yes
  end
end
