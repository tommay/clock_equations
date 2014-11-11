# Evaluate expressions using a Pratt parser.

class PrattEvaluator
  def self.eval(expression)
    PrattEvaluator.new(expression).eval
  end

  def initialize(expression)
    tokens = {
      "=" => EqualsToken.new(self),
      "+" => AddToken.new(self),
      "-" => SubToken.new(self),
      "*" => MulToken.new(self),
      "/" => DivToken.new(self),
    }
    (0..9).each do |d|
      tokens[d.to_s] = DigitToken.new(self, d.to_f)
    end

    @tokens = expression.each_char.map do |c|
      tokens[c]
    end.each

    @token = nil
  end

  def next_token
    @tokens.next rescue EndToken.new
  end

  def eval
    @token = next_token
    expression
  end

  def expression(rbp = 0)
    t = @token
    @token = next_token
    left = t.nud
    more_expression(rbp, left)
  end

  def more_expression(rbp, left)
    if rbp < @token.lbp
      t = @token
      @token = next_token
      more_expression(rbp, t.led(left))
    else
      left
    end
  end

  class Token
    def initialize(evaluator, lbp)
      @evaluator = evaluator
      @lbp = lbp
    end

    def lbp
      @lbp
    end

    def expression(rbp = @lbp)
      @evaluator.expression(rbp)
    end
  end

  class EqualsToken < Token
    def initialize(evaluator)
      super(evaluator, 8)
    end

    def led(left)
      left == expression
    end
  end

  class EndToken
    def lbp
      0
    end
  end

  class AddToken < Token
    def initialize(evaluator)
      super(evaluator, 10)
    end

    def led(left)
      left + expression
    end
  end

  class SubToken < AddToken
    def led(left)
      left - expression
    end
  end

  class MulToken < Token
    def initialize(evaluator)
      super(evaluator, 20)
    end

    def led(left)
      left * expression
    end
  end

  class DivToken < MulToken
    def led(left)
      left / expression
    end
  end

  class DigitToken < Token
    def initialize(evaluator, value)
      super(evaluator, 100)
      @value = value
    end

    def nud
      @value
    end

    def led(left)
      left*10 + @value
    end
  end
end