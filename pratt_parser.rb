# A Pratt parser.  Similar to a recursive decent parser but instead of
# coding a function for each production, the syntax is coded in a set
# of token objects that are yielded by the lexer.  New operators and
# statements can be slipped in to the language with the proper
# precedence by adding new token objects to the lexer without altering
# the code for existing tokens.  Pretty cool.
#
# lexer is an enumerator with a next method that returns token objects
# with three methods:
# lbp: return the operator precedence.  Higher numbers bind more tightly.
# nud(parser): called when the token is returned with nothing to the left
#   of it to cobine with, e.g., a unary operator "+1".
# led(parser, left): combine left, which is the parsed expression to the
#   left of the operator, with the expression to the right of the operator.
# Only lbp is mandatory.  nud and led will be called only when necessary, if
# ever.
# nud and lcd can call parser.expression(rbp) to recursively parse the
# right expression.  rbp should be the token's lbp for left-associativity,
# lbp-1 for right.
#
# PrattParser.new(lexer).eval will return the result of the parse.
#
# Syntax errors aren't handled at the moment and will cause ridiculous
# exceptions to be raised such as NoMethodError.

# http://javascript.crockford.com/tdop/tdop.html
# http://effbot.org/zone/simple-top-down-parsing.htm
# http://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy/

class PrattParser
  def initialize(lexer)
    @lexer = Enumerator.new do |y|
      lexer.each do |token|
        y << token
      end
      y << EndToken.new
    end

    @token = nil
  end

  def eval
    @token = @lexer.next
    expression(0)
  end

  def expression(rbp)
    t = @token
    @token = @lexer.next
    left = t.nud(self)
    while rbp < @token.lbp
      t = @token
      @token = @lexer.next
      left = t.led(self, left)
    end
    left
  end

  class EndToken
    def lbp
      0
    end
  end
end
