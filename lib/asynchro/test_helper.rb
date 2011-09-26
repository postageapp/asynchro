require 'eventmachine'

module Asynchro::TestHelper
  # Wraps a given block in an EventMachine run loop. Because this loop will
  # monopolize the thread, a new thread is created to execute the supplied
  # block. Exceptions are trapped from both the supplied block and the
  # engine and raised accordingly.
  def eventmachine
    exception = nil

    Thread.new do
      Thread.abort_on_exception = true

      # Create a thread for the engine to run on
      begin
        EventMachine.run do
          Thread.new do
            # Execute the test code in a separate thread to avoid blocking
            # the EventMachine loop.
            begin
              yield
            rescue Object => exception
            ensure
              begin
                EventMachine.stop_event_loop
              rescue Object
                # Shutting down may trigger an exception from time to time
                # if the engine itself has failed.
              end
            end
          end
        end
      rescue Object => exception
      end
    end.join
    
    if (exception)
      raise exception
    end
  end

  # Asserts that a callback is made within a specified time, or will wait
  # forever for the callback to occur if no time is specified. The supplied
  # block will be called with the callback Proc which should be executed
  # using `call` exactly once.
  def assert_callback(time = nil, message = nil)
    called_back = false
    
    Pigeonrocket.execute_in_main_thread do
      yield(lambda { called_back = true })
    end
    
    start_time = Time.now.to_i

    while (!called_back)
      select(nil, nil, nil, 0.1)
      
      if (time and (Time.now.to_i - start_time > time))
        flunk(message || 'assert_callback timed out')
      end
    end
  end

  # Asserts that a callback is made within a specified time, or will wait
  # forever for the callback to occur if no time is specified. The supplied
  # block will be called with the callback Proc which should be executed
  # using `call` as many times as specified, or 1 by default.
  def assert_callback_times(count = 1, time = nil, message = nil)
    called_back = 0
    
    Pigeonrocket.execute_in_main_thread do
      yield(lambda { called_back += 1 })
    end
    
    start_time = Time.now.to_i

    while (called_back < count)
      select(nil, nil, nil, 0.1)
      
      if (time and (Time.now.to_i - start_time > time))
        flunk(message || "assert_callback_times timed out at only #{count} times")
      end
    end
  end
  
  # Tests and re-tests assertions until all of them will pass. An optional
  # limit on time can be specified in seconds. A short delay is introduced
  # between tests to avoid monopolizing the CPU during testing. When the
  # supplied block fails to produce an exception it is presumed to have been
  # a successful test and execution will continue as normal.
  def assert_eventually(time = nil, message = nil)
    end_time = (time and Time.now + time)
    exception = nil

    while (true)
      begin
        yield
      rescue Object => e
        exception = e
      else
        break
      end
      
      select(nil, nil, nil, 0.1)
      
      if (end_time and Time.now > end_time)
        if (exception)
          raise exception
        else
          flunk(message || 'assert_eventually timed out')
        end
      end
    end
  end
end
