class Asynchro::Tracker
  # Creates a new tracker. If a block is given, this block is called with
  # the new instance as an argument, and the tracker is automatically run.
  def initialize(context = self)
    @sequence = 0
    @context = context
    
    if (block_given?)
      instance_eval(&Proc.new)
      self.run!
    end
  end
  
  # Runs through the tasks to perform for this tracker. Should only be
  # called if this object is initialized without a supplied block as in that
  # case, this would have been called already.
  def run!
    @procs and @procs.each { |proc| @context.instance_eval { proc.call } }
  end
  
  # Executes this block when all the actions to be performed have checked in
  # as finsished.
  def finish(&block)
    @finish ||= [ ]
    @finish << block
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
      
        if (@blocks.empty?)
          @finish and @finish.each { |proc| @context.instance_eval { proc.call } }
        end
      end
    }
    
    @procs ||= [ ]
    @procs << lambda { block.call(callback) }
  end
end
