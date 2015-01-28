# Evaluate expressions using a PrattParser.

require_relative "pratt_parser"

class PrattEvaluator
  def self.eval(expression)
    PrattParser.new(Lexer.new(expression)).eval
  end

  class Lexer
    # Note that new returns an Enumerator, not a Lexer.

    def self.new(expression)
      expression.each_char.lazy.map{|c|@@tokens[c]}
    end

    class Token
      def initialize(lbp)
        @lbp = lbp
      end

      def lbp
        @lbp
      end
    end

    class InfixToken < Token
      def initialize(lbp, sym, associates = :left)
        super(lbp)
        @sym = sym
        @rbp = (associates == :left ? lbp : lbp - 1)
      end

      def led(parser, left)
        left.send(@sym, parser.expression(@rbp))
      end
    end

    class DigitToken < Token
      def initialize(lbp, value)
        super(lbp)
        @value = value
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
    
    class LeftParenToken < Token
      def nud(parser)
        parser.expression(lbp).tap do
          parser.expect(RightParenToken)
        end
      end
    end
    
    class RightParenToken < Token
    end
    
    @@tokens = {}
    
    def self.token(char, t)
      @@tokens[char] = t
    end

    def self.infix(char, lbp, sym, associates = :left)
      token(char, InfixToken.new(lbp, sym, associates))
    end

    token("(", LeftParenToken.new(0))
    token(")", RightParenToken.new(0))

    infix("=", 10, :==)
    infix("+", 20, :+)
    infix("-", 20, :-)
    infix("*", 30, :*)
    infix("/", 30, :/)
    infix("^", 40, :**, :right)

    (0..9).each do |d|
      token(d.to_s, DigitToken.new(100, d.to_f))
    end
  end
end
