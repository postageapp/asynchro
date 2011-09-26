module Asynchro::Extensions
  def async_tracker(&block)
    Asynchro::Tracker.new(&block)
  end

  def async_state(&block)
    Asynchro::State.new(&block)
  end
end
