# Evaluate expressions using a Pratt parser.

require "byebug"

# http://javascript.crockford.com/tdop/tdop.html
# http://effbot.org/zone/simple-top-down-parsing.htm
# http://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/

class PrattEvaluator
  def self.eval(expression)
    PrattEvaluator.new(expression).eval
  end

  class Token
    def initialize(lbp)
      @lbp = lbp
    end

    def lbp
      @lbp
    end
  end

  class EqualsToken < Token
    def initialize
      super(8)
    end

    def led(evaluator, left)
      left == evaluator.expression(lbp)
    end
  end

  class EndToken
    def lbp
      0
    end
  end

  class AddToken < Token
    def initialize
      super(10)
    end

    def led(evaluator, left)
      left + evaluator.expression(lbp)
    end
  end

  class SubToken < AddToken
    def led(evaluator, left)
      left - evaluator.expression(lbp)
    end
  end

  class MulToken < Token
    def initialize
      super(20)
    end

    def led(evaluator, left)
      left * evaluator.expression(lbp)
    end
  end

  class DivToken < MulToken
    def led(evaluator, left)
      left / evaluator.expression(lbp)
    end
  end

  class DigitToken < Token
    def initialize(value)
      super(100)
      @value = value
    end

    def nud(evaluator)
      @value
    end

    def led(evaluator, left)
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

  def initialize(expression)
    @tokens = Enumerator.new do |y|
      expression.each_char do |c|
        y << @@tokens[c]
      end
      y << EndToken.new
    end

    @token = nil
  end

  def next_token
    @tokens.next
  end

  def eval
    @token = next_token
    expression
  end

  def expression(rbp = 0)
    t = @token
    @token = next_token
    left = t.nud(self)
    more_expression(rbp, left)
  end

  def more_expression(rbp, left)
    if rbp < @token.lbp
      t = @token
      @token = next_token
      more_expression(rbp, t.led(self, left))
    else
      left
    end
  end
end
