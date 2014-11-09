# Messing around with building my own Enumerator class using class Coroutine,
# which is much simpler than using callcc directly.

require_relative "coroutine.rb"

class CoroutineEnumerator
  include Enumerable

  def initialize(&block)
    @done = false
    @coroutine = Coroutine.new do
      block.call(self)
      @done = true
      raise StopIteration
    end
  end

  def next
    if @done
      raise StopIteration
    end

    @coroutine.switch
  end

  def <<(value)
    @coroutine.switch(value)
  end

  def each(&block)
    begin
      while true
        block.call(self.next)
      end
    rescue StopIteration
    end
  end
end
