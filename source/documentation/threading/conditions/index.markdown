---
layout: page
title: "Thread Conditions"
date: 2012-05-25 19:44
sharing: true
comments: false
footer: false
sidebar: false
categories: [Thread Utilities]

---

## Wait for a Thread to be in a State

`Conditions.isWaiting(Thread thread)`

A Condition that allows you to test if a thread is in a waiting state. Combining the condition with some classes from the [temporal](time.html#Conditions_and_Waiting) package allows you to wait for a thread to be in the waiting state. For example,


{% codeblock lang:java %}
waitOrTimeout(isWaiting(thread), timeout(seconds(10)));
{% endcodeblock %}


`Conditions.is(Thread thread, Thread.State state)`

A more general purpose `Condition` to check that a thread is in a given state. For example,


{% codeblock lang:java %}
waitOrTimeout(is(thread, TERMINATED), timeout(seconds(10)));
{% endcodeblock %}


`Conditions.isAlive(Thread thread)`

Checks that a thread is alive. A thread is alive if it has been started and has not yet died. For example,


{% codeblock lang:java %}
System.out.println(isAlive(Thread.currentThread()));
{% endcodeblock %}


## Wait for an Executor to Shutdown

`Conditions.shutdown(ExecutorService service)`

Checks that a `java.util.concurrent.ExecutorService` has been shutdown according to the result of the it's `isShutdown` method. This might be useful if you'd like to wait for shutdown. The tempus-fugit `ExecutorServiceShutdown` class does just this.


{% codeblock lang:java %}
waitOrTimeout(Conditions.shutdown(executor), timeout);
{% endcodeblock %}



## Invert a Condition

`Conditions.not(Condition condition)`

The `NotCondition` will negate the logical result of some other condition. For example, we can change the example above to wait until a thread is _not_ in a waiting state by using the following.


{% codeblock lang:java %}
waitOrTimeout(not(isWaiting(thread)), timeout(seconds(10)));
{% endcodeblock %}



[Next, Thread Utilities: Miscellaneous &raquo;](/documentation/threading/misc)
