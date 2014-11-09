#!/usr/bin/env ruby

# My 9-year old daughter Chloe and I like to look at the digital clock
# sometimes and make equations out of the numbers.  For example,
# 12:02 could be 1*2+0 = 2, and 12:03 could be 1+2 = 0+3.
#
# I thought it would be fun to code up a program to find all the
# "clock eauations".  There are two parts: generating the equations,
# and evaluating their truth value.

require "stringio"
require_relative "fiber_enumerator"
require_relative "callcc_enumerator"

#UseEnumerator = Enumerator
#UseEnumerator = FiberEnumerator
UseEnumerator = CallccEnumerator

def main
  time_and_equations.each do |time, equation|
    puts "#{time} => #{equation.gsub(/\b/, " ").strip}"
  end
end

class UseEnumerator
  def chain(&block)
    UseEnumerator.new do |y|
      self.each do |element|
        block.call(element, y)
      end
    end
  end
end

def time_and_equations
  times = UseEnumerator.new do |y|
    (1..12).each do |hour|
      (0..59).each do |minute|
        y << "%d:%02d" % [hour, minute]
      end
    end
  end

  # Create all equations for each time:
  # [[time0, equation0], [time0, equation1], ..., [timeN, equation0], ...]

  time_and_equations = times.chain do |time, y|
    equations_for_time(time).each do |equation|
      y << [time, equation]
    end
  end

  # Filter for valid time/equations.

  valid_time_and_equations = time_and_equations.chain do |(time, equation), y|
    if Evaluator.eval(equation)
      y << [time, equation]
    end
  end

  # Return them.

  valid_time_and_equations
end

def equations_for_time(time)
  time_digits = time.sub(/:/, "").chars
  
  # We're going to take the time and intersperse the digits with
  # all combinations of operators.  Except we only allow one "=".
  # ops is the array of all possible operator combinations of the
  # correct length to intersperse with the time.
  
  ops = ([["=", "+", "-", "*", "/", ""]] * (time_digits.size - 1))
    .reduce(&:product)
    .map(&:flatten)
    .select{|x| x.count("=") == 1}
  
  # Zip each operator set into the digits and join the result to
  # make a string.  If the string evaluates as true, print it out.
  
  ops.map do |op_array|
    time_digits.zip(op_array).flatten.join
  end
end

class Evaluator
  def self.eval(expression)
    StringIO.open(expression) do |io|
      equality(io)
    end
  end

  def self.equality(io)
    left = sum(io)
    if io.getc != "="
      raise "expected ="
    end
    right = sum(io)
    left == right
  end

  # Oops, these need to be left associative else
  # 0-1-1 = 0-(1-1) = 0 instead of -2.

  def self.sum(io)
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

  def self.sum(io)
    left = product(io)
    more_sum(left, io)
  end

  def self.more_sum(left, io)
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

  def self.product(io)
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

  def self.product(io)
    left = number(io)
    more_product(left, io)
  end

  def self.more_product(left, io)
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

  def self.number(io)
    c = io.getc
    if c < "0" || c > "9"
      raise "expected 0-9"
    end
    more_number(c.to_f, io)
  end

  def self.more_number(n, io)
    c = io.getc
    if c.nil? || c < "0" || c > "9"
      io.ungetc(c)
      n
    else
      more_number(n*10 + c.to_f, io)
    end
  end
end

if __FILE__ == $0
  main
end
