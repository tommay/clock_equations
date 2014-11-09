require "continuation"

class Coroutine
  def initialize(&block)
    @block = block
    @cont = nil
  end

  def switch(value = nil)
    # We can simply return the value from callcc because it will never
    # return a Continuation here because the block will never reach
    # its end.  The value returned by callcc, and therefore switch,
    # will be the value passed to switch from the other coroutine.

    callcc do |cc|
      cont = @cont
      @cont = cc
      if !cont
        @block.call
      else
        cont.call(value)
      end
    end
  end
end
