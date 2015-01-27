require "rubygems"
require "bundler/setup"
require "minitest/autorun"

require_relative "../pratt_evaluator"

describe PrattEvaluator do
  it "evaluates single digit numbers" do
    PrattEvaluator.eval("1").must_equal 1
  end

  it "evaluates multi-digit numbers" do
    PrattEvaluator.eval("123").must_equal 123
  end

  it "evaluates sums" do
    PrattEvaluator.eval("1+2+3").must_equal 6
  end

  it "evaluates differences with left association" do
    PrattEvaluator.eval("4-2-1").must_equal 1
  end

  it "evaluates sums and differences with left association" do
    PrattEvaluator.eval("4+2-1+3").must_equal 8
  end

  it "evaluates products" do
    PrattEvaluator.eval("2*3*4").must_equal 24
  end

  it "evaluates quotients with left association" do
    PrattEvaluator.eval("12/4/3").must_equal 1
  end

  it "evaluates quotients with left association" do
    PrattEvaluator.eval("12/4/3").must_equal 1
  end

  it "evaluates products and quotients with left association" do
    PrattEvaluator.eval("12*4/3*5").must_equal 80
  end

  it "evaluates * and / before + and -" do
    PrattEvaluator.eval("1+2*3-4*5+8/2-10/5").must_equal -11
  end

  it "evaluates exponents with right accociation" do
    PrattEvaluator.eval("4^3^2").must_equal 4**3**2
  end

  it "evaluates ^ before *" do
    PrattEvaluator.eval("2*3^2").must_equal 18
  end

  it "evaluates expressions in parentheses first" do
    PrattEvaluator.eval("2*(3+4)").must_equal 14
  end

  it "allows nested parentheses" do
    PrattEvaluator.eval("(2*(3+4))^2").must_equal 196
  end

  it "evaluates fancy expressions" do
    PrattEvaluator.eval("2*(3+4)^2=98").must_equal true
  end

  it "evaluates = expressions" do
    PrattEvaluator.eval("1=2").must_equal false
    PrattEvaluator.eval("2=2").must_equal true
  end
    
  it "evaluates = after + and -" do
    PrattEvaluator.eval("1+2=8-5").must_equal true
  end

  it "fails on expressions starting with an operator" do
    ["+", "-", "*", "/", "^", "="].each do |op|
      assert_raises NoMethodError do
        PrattEvaluator.eval("#{op}4")
      end
    end
  end
end
