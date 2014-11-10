require "stringio"

class Evaluator
  def self.eval(expression)
    Evaluator.new(expression).eval
  end

  def initialize(expression)
    @expression = expression
  end

  def eval
    StringIO.open(@expression) do |io|
      equality(io)
    end
  end

  def equality(io)
    left = sum(io)
    if io.getc != "="
      raise "expected ="
    end
    right = sum(io)
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

  def sum(io)
    left = product(io)
    more_sum(left, io)
  end

  def more_sum(left, io)
    c = io.getc
    case c
    when "+"
      more_sum(left + product(io), io)
    when "-"
      more_sum(left - product(io), io)
    else
      io.ungetc(c)
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

  def product(io)
    left = number(io)
    more_product(left, io)
  end

  def more_product(left, io)
    c = io.getc
    case c
    when "*"
      more_product(left * number(io), io)
    when "/"
      more_product(left / number(io), io)
    else
      io.ungetc(c)
      left
    end
  end

  def number(io)
    c = io.getc
    if c < "0" || c > "9"
      raise "expected 0-9"
    end
    more_number(c.to_f, io)
  end

  def more_number(n, io)
    c = io.getc
    if c.nil? || c < "0" || c > "9"
      io.ungetc(c)
      n
    else
      more_number(n*10 + c.to_f, io)
    end
  end
end
