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

  def nextc
    @c = @io.getc
  end

  def equality
    left = sum
    if @c != "="
      raise "expected ="
    end
    nextc
    right = sum
    left == right
  end

  # Oops, these need to be left associative else
  # 0-1-1 = 0-(1-1) = 0 instead of -2.

  def sum(io)
    left = product(io)
    c = io.getc
    case c
    when "+"
      left + sum(io)
    when "-"
      left - sum(io)
    else
      io.ungetc(c)
      left
    end
  end

  # Left-associatuve version.

  def sum
    left = product
    more_sum(left)
  end

  def more_sum(left)
    case @c
    when "+"
      nextc
      more_sum(left + product)
    when "-"
      nextc
      more_sum(left - product)
    else
      left
    end
  end

  # Right-associative version.

  def product(io)
    left = number(io)
    c = io.getc
    case c
    when "*"
      left * product(io)
    when "/"
      left / product(io)
    else
      io.ungetc(c)
      left
    end
  end

  # Left-associative version.

  def product
    left = number
    more_product(left)
  end

  def more_product(left)
    case @c
    when "*"
      nextc
      more_product(left * number)
    when "/"
      nextc
      more_product(left / number)
    else
      left
    end
  end

  def number
    if @c < "0" || @c > "9"
      raise "expected 0-9"
    end
    n = @c.to_f
    nextc
    more_number(n)
  end

  def more_number(n)
    if @c.nil? || @c < "0" || @c > "9"
      n
    else
      n = n*10 + @c.to_f
      nextc
      more_number(n)
    end
  end
end
