# Messing around with building my own Enumerator class using Fiber.

require "continuation"

class CallccEnumerator
  include Enumerable

  def initialize(&block)
    @block = block
  end

  def next
    if @done
      raise StopIteration
    end

    # We only get to call the block once, and it does its thing and
    # calls yielder.<< as many times as necessary.  We need to do
    # callcc to save our place on every call to next and on every
    # yield, since the place we need to return to may/will vary.

    # Note our current context in @to_enumerator then switch to the
    # block, either by starting it if we haven't yet (@to_block is
    # nil) or via @to_block.call.

    # yield does the reverse: note our context in @to_block then jump
    # via @to_enumerator, passing the value for next to return.

    # We can simply return the value from callcc because it will never
    # regturn a Continuation here because the block will never reach
    # its end.  The values returned by callcc will be the values
    # passed to @to_enumerator.call in <<.

    callcc do |cc|
      @to_enumerator = cc
      if !@to_block
        @block.call(self)
        @done = true
        raise StopIteration
      else
        @to_block.call
      end
    end
  end

  def <<(value)
    @to_block = callcc{|cc|cc}
    if @to_block
      @to_enumerator.call(value)
    end
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
