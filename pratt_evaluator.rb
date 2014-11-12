# Evaluate expressions using a PrattParser.

require_relative "pratt_parser"

class PrattEvaluator
  def self.eval(expression)
    PrattEvaluator.new(expression).eval
  end

  def initialize(expression)
    @expression = expression
  end

  def eval
    PrattParser.new(@expression.each_char.lazy.map{|c|@@tokens[c]}).eval
  end

  class EqualsToken
    def lbp
      8
    end

    def led(parser, left)
      left == parser.expression(lbp)
    end
  end

  class AddToken
    def lbp
      10
    end

    def led(parser, left)
      left + parser.expression(lbp)
    end
  end

  class SubToken < AddToken
    def led(parser, left)
      left - parser.expression(lbp)
    end
  end

  class MulToken
    def lbp
      20
    end

    def led(parser, left)
      left * parser.expression(lbp)
    end
  end

  class DivToken < MulToken
    def led(parser, left)
      left / parser.expression(lbp)
    end
  end

  class DigitToken
    def initialize(value)
      @value = value
    end

    def lbp
      100
    end

    def nud(parser)
      @value
    end

    def led(parser, left)
      left*10 + @value
    end
  end

  @@tokens = {
    "=" => EqualsToken.new,
    "+" => AddToken.new,
    "-" => SubToken.new,
    "*" => MulToken.new,
    "/" => DivToken.new,
  }
  (0..9).each do |d|
    @@tokens[d.to_s] = DigitToken.new(d.to_f)
  end
end
