#!/usr/bin/env ruby

# My 9-year old daughter Chloe and I like to look at the digital clock
# sometimes and make equations out of the numbers.  For example,
# 12:02 could be 1*2+0 = 2, and 12:03 could be 1+2 = 0+3.
#
# I thought it would be fun to code up a program to find all the
# "clock eauations".  There are two parts: generating the equations,
# and evaluating their truth value.

require_relative "evaluator"
require_relative "pratt_evaluator"

def main
  time_and_equations.each do |time, equation|
    puts "#{time} => #{equation.gsub(/\b/, " ").strip}"
  end
end

def time_and_equations
  # Generate each time.
  # Both the ranges need to use .lazy to get full laziness.

  times = (1..12).lazy.flat_map do |hour|
    (0..59).lazy.map do |minute|
      "%d:%02d" % [hour, minute]
    end
  end

  # Create all equations for each time:
  # [[time0, equation0], [time0, equation1], ..., [timeN, equation0], ...]

  time_and_equations = times.flat_map do |time|
    [time].product(equations_for_time(time))
  end

  # Select the valid time/equations.

  valid_time_and_equations = time_and_equations.select do |time, equation|
    PrattEvaluator.eval(equation)
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

if __FILE__ == $0
  main
end
