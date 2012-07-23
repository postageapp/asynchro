module Asynchro::Extensions
  def async_tracker(&block)
    Asynchro::Tracker.new(&block)
  end

  def async_state(&block)
    Asynchro::State.new(&block)
  end
  
  def yield_to
    this = Fiber.current
    
    fiber = Fiber.new do
      yield(lambda { fiber.transfer(this) })
    end

    fiber.transfer(fiber)
  end
end
