require "stringio"

class Evaluator
  def self.eval(expression)
    Evaluator.new(expression).eval
  end

  def initialize(expression)
    @expression = expression
    @io = nil
    @c = nil
  end

  def eval
    StringIO.open(@expression) do |io|
      @io = io
      nextc
      equality
    end
  end

  # Fetch the next character and return the current character.

  def nextc
    @c.tap{@c = @io.getc}
  end

  # Test the current character against either the given character or
  # the block.  If it matches, fetch the next character and return the
  # current character, else return nil.

  def next?(c = nil, &block)
    if block
      if block.call(@c)
        nextc
      end
    else
      if @c == c
        nextc
      end
    end
  end

  def equality
    left = sum
    if !next?("=")
      raise "expected ="
    end
    right = sum
    left == right
  end

  def sum
    left = product()
    more_sum(left)
  end

  def more_sum(left)
    case
    when next?("+")
      more_sum(left + product)
    when next?("-")
      more_sum(left - product)
    else
      left
    end
  end

  def product
    left = number
    more_product(left)
  end

  def more_product(left)
    case
    when next?("*")
      more_product(left * number)
    when next?("/")
      more_product(left / number)
    else
      left
    end
  end

  def number
    if c = next?{|c| c >= "0" && c <= "9"}
      more_number(c.to_f)
    else
      raise "expected 0-9"
    end
  end

  def more_number(n)
    if c = next?{|c| c != nil && c >= "0" && c <= "9"}
      more_number(n*10 + c.to_f)
    else
      n
    end
  end
end
