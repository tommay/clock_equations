# Messing around with building my own Enumerator class using Fiber.

require "fiber"

class FiberEnumerator
  include Enumerable

  def initialize(&block)
    @fiber = Fiber.new do
      block.call(Yielder)
      raise "I'm done"
    end
  end

  def next
    @fiber.resume
  end

  def each(&block)
    while @fiber.alive?
      block.call(self.next)
    end
  end

  class Yielder
    def self.<<(value)
      Fiber.yield(value)
    end
  end
end

