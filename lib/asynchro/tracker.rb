class Asynchro::Tracker
  # Creates a new tracker. If a block is given, this block is called with
  # the new instance as an argument, and the tracker is automatically run.
  def initialize
    @sequence = 0
    
    if (block_given?)
      yield(self)
      
      Fiber.new do
        self.run!
      end.resume
    end
  end
  
  # Performs an action. The supplied block will be called with a callback
  # tracking Proc that should be triggered with `call` as many times as
  # are specified in the `count` argument. When the correct number of calls
  # have been made, this action is considered finished.
  def perform(count = 1, *args)
    @operations ||= { }

    _sequence = @sequence += 1
    @operations[_sequence] = true

    fiber = Fiber.new do
      called = false
      should_resume = false

      callback = lambda {
        called = true

        if (should_resume)
          fiber.resume
        end
      }

      count.times do
        called = false

        yield(callback, *args)

        unless (called)
          should_resume = true
          Fiber.yield
        end
      end

      @operations.delete(_sequence)

      if (self.finished?)
        self.finish!
      end
    end

    (@fibers ||= [ ]) << fiber
  end

  # Executes this block when all the actions to be performed have checked in
  # as finsished.
  def finish(&block)
    (@finish ||= [ ]) << block
  end
  
  # Returns true if this tracker has completed all supplied blocks, or false
  # otherwise.
  def finished?
    !@operations or @operations.empty?
  end
  
protected
  # Runs through the tasks to perform for this tracker. Should only be
  # called if this object is initialized without a supplied block as in that
  # case, this would have been called already.
  def run!
    if (self.finished?)
      self.finish!
    else
      @fibers.each(&:resume)
    end
  end

  # Executes the defined finish blocks and resumes execution
  def finish!
    @finish and @finish.each(&:call)
  end
end
