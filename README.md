clock_equations
===============

Figure out the simple equations that can be made from the time on a digital clock

My 9-year old daughter Chloe and I like to look at the digital clock
sometimes and make equations out of the numbers.  For example,
12:02 could be 1*2+0 = 2, and 12:03 could be 1+2 = 0+3.

I thought it would be fun to code up a program to find all the "clock
eauations".  There are two parts: generating the equations, and
evaluating their truth value.  Generating the equations done one
of two ways:

- clock.rb uses a sequence of `.lazy` enumerators to generate the times,
build all possible equations from the numbers of each tine, and filter
the valid equations.

- enum_clock.rb uses explicit enumerators of various kinds, mostly to see
how things weould come out if I coded them up;
    <dl>
       <dt>Enumerator</dt>
       <dd>Standard Ruby Enumerator</dd>
       <dt>FiberEnumerator</dt>
       <dd>Enumerator using Fiber (fiber_enumerator.rb).  This is
           straightforward.<br></dd>
       <dt>CallccEnumerator</dt>
       <dd>Enumerator using bare callcc (callcc_enumerator.rb).  This one
           is not particularly nice or well-done.</dd>
       <dt>CoroutineEnumerator</dt>
       <dd>Enumerator that encapsulates the callcc usage into a
           Coroutine class.  This one is pretty good.
           (coroutine_enumerator.rb, coroutine.rb)</dd>
    </dl>
    The `Enumerator` class can be set by editing enum_clock.rb and setting
    variable `UseEnumerator` to the proper class (ugh).

The equations' truth values are determined using a recursive descent
expression evaluator.

    
