require "continuation"

# For some reason calling Fiber.current prevents a "coroutine.rb:25:in
# `call': continuation called across fiber (RuntimeError)" which
# started happening after switching Evaluator from StringIO to
# String#each_char.

require "fiber"
Fiber.current

class Coroutine
  def initialize(&block)
    # The initial "continuation" is the coroutine block.  This results
    # in any arguments passed to the initial "switch" being passed to
    # the coroutine as block arguments, ala Fiber!

    @cont = block
  end

  def switch(*values)
    # We can simply return the value from callcc because it will never
    # return a Continuation here because the block will never reach
    # its end.  The value returned by callcc, and therefore switch,
    # will be the value passed to switch from the other coroutine.

    callcc do |cc|
      cont = @cont
      @cont = cc
      cont.call(*values)
    end
  end
end
