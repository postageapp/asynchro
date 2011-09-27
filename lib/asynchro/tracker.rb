class Asynchro::Tracker
  # Creates a new tracker. If a block is given, this block is called with
  # the new instance as an argument, and the tracker is automatically run.
  def initialize
    @sequence = 0
    
    if (block_given?)
      yield(self)

      self.run!
    end
  end
  
  # Runs through the tasks to perform for this tracker. Should only be
  # called if this object is initialized without a supplied block as in that
  # case, this would have been called already.
  def run!
    if (@procs)
      @procs.each(&:call)
    else
      @finish and @finish.each(&:call)
    end
  end
  
  # Executes this block when all the actions to be performed have checked in
  # as finsished.
  def finish(&block)
    @finish ||= [ ]
    @finish << block
  end
  
  # Returns true if this tracker has completed all supplied blocks, or false
  # otherwise.
  def finished?
    !@blocks or @blocks.empty?
  end
  
  # Performs an action. The supplied block will be called with a callback
  # tracking Proc that should be triggered with `call` as many times as
  # are specified in the `count` argument. When the correct number of calls
  # have been made, this action is considered finished.
  def perform(count = 1, &block)
    @blocks ||= { }

    _sequence = @sequence += 1
    @blocks[_sequence] = count

    callback = lambda {
      if (@blocks[_sequence])
        if ((@blocks[_sequence] -=1) <= 0)
          @blocks.delete(_sequence)
        end
      
        if (self.finished?)
          @finish and @finish.each(&:call)
        end
      end
    }
    
    @procs ||= [ ]
    @procs << lambda { block.call(callback) }
  end
end
