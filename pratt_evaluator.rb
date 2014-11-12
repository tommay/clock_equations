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
    PrattParser.new(Lexer.new(@expression)).eval
  end

  class Lexer
    # Note that new returns an Enumerator, not a Lexer.

    def self.new(expression)
      expression.each_char.lazy.map{|c|@@tokens[c]}
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
    
    # The simple clock expressions don't use parentheses.  These are
    # just here to see how easy it is to slip new rules into a
    # grammar.  It is indeed easy.  No need to modify existing rules
    # or recompile a BNF grammar.
    
    class LeftParenToken
      def lbp
        0
      end
      
      def nud(parser)
        parser.expression(lbp).tap do
          parser.expect(RightParenToken)
        end
      end
    end
    
    class RightParenToken
      def lbp
        0
      end
    end
    
    @@tokens = {
      "=" => EqualsToken.new,
      "+" => AddToken.new,
      "-" => SubToken.new,
      "*" => MulToken.new,
      "/" => DivToken.new,
      "(" => LeftParenToken.new,
      ")" => RightParenToken.new,
    }
    (0..9).each do |d|
      @@tokens[d.to_s] = DigitToken.new(d.to_f)
    end
  end
end
