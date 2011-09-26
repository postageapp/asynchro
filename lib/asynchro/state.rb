class Asynchro::State
  # Create a state map object. If a block is given, it is called with the
  # instance created, then that instance is run.
  def initialize(&block)
    @states = {
      :finish => [ ]
    }
    
    if (block_given?)
      case (block.arity)
      when 0
        instance_exec(&block)
      else
        block.call(self)
      end
    
      self.run!
    end
  end
  
  # Declares the action to be taken when a particular state is entered. The
  # argument is the state name and should be a Symbol. A block must be
  # provided. If this state is already declared, the given block will be
  # executed after the previous declarations.
  def declare(state, &block)
    (@states[state.to_sym] ||= [ ]) << block
  end

  # Returns true if a particular state has been declared, false otherwise.
  def declared?(state)
    !!@states[state]
  end
  
  # Runs a particular state, or if the state is not specified, then :start
  # by default.
  def run!(state = :start)
    procs = @states[state.to_sym]
    
    case (state)
    when :start
      procs = [ lambda { finish! } ] unless (procs)
    end
    
    if (procs)
      procs.each(&:call)
    else
      STDERR.puts "WARNING: No state #{state} defined."
    end
  end

protected
  # This lets the object instance function as a simple DSL by allowing
  # arbitrary method names to map to various functions.
  def method_missing(name, *args, &block)
    name_s = name.to_s
    
    if (args.empty?)
      case (name)
      when /\?$/
        self.declared?(name_s.sub(/\?$/, ''))
      when /\!$/
        self.run!(name_s.sub(/\!$/, ''))
      else
        self.declare(name, &block)
      end
    else
      super(name, *args)
    end
  end
end
