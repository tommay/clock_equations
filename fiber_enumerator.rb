# Messing around with building my own Enumerator class using Fiber.

require "fiber"

class FiberEnumerator
  include Enumerable

  def initialize(&block)
    @fiber = Fiber.new do
      block.call(Yielder)
      raise StopIteration
    end
  end

  # Enumerable builds everything on top of each.

  def each(&block)
    begin
      while true
        block.call(@fiber.resume)
      end
    rescue StopIteration
    end
  end

  # The Yielder passed to the block can be any object with a << method.

  class Yielder
    def self.<<(value)
      Fiber.yield(value)
    end
  end
end

