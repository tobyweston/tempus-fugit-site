---
layout: page
title: "Testing Interrupts"
date: 2012-05-26 17:17
sharing: true
comments: false
footer: false
sidebar: false
categories: [JUnit Integration]
---

It can be tricky to test that an interrupt has been called on a thread because of the possibility of race conditions between calling `interrupt` and checking the status of the interrupt flag using `Thread.isInterrupted()` or `Thread.interrupted`. For example, the interrupt status can be reset when a thread goes into the `TERMINATED` state. You can use the `WaitFor` class to express an assertion must be true within a given time (as below) but in this case, the race conditions can still occur (due to the frequency of the check whilst waiting). In the example below, the created thread will perform some blocking function that can be interrupted (for example, sleeping) and we're testing that the call to `interrupt` will wake and change the interrupt status flag (asserting against `thread.isInterrupted`).



{% codeblock lang:java %}
@Test (timeout = 500)
public void interrupted() throws TimeoutException, InterruptedException {
    final Thread thread = new Thread(new Runnable(...));
    thread.start();
    waitOrTimeout(threadIsWaiting(thread), millis(500));
    thread.interrupt();
    waitOrTimeout(new Condition() {
        public boolean isSatisfied() {
            return thread.isInterrupted();
        }
    }, millis(500));
}{% endcodeblock %}


It may be simpler to use a _stub_ to capture the interrupt. The `InterruptCapturingThread` class of tempus-fugit is just a stub extending `Thread` which records and gives access to stack traces of threads that call `interrupt` on it.



{% codeblock lang:java %}
@Test (timeout = 500)
public void interrupted() throws TimeoutException, InterruptedException {
    InterruptCapturingThread thread = new InterruptCapturingThread(new Runnable(...));
    thread.start();
    waitOrTimeout(threadIsWaiting(thread), millis(500));
    thread.interrupt();
    waitOrTimeout(not(threadIsWaiting(thread)), millis(500));
    assertThat(thread.getInterrupters().isEmpty(), is(false));
}{% endcodeblock %}


For testing purposes, you can also get a view on the stack traces of the threads that called `interrupt` on your thread. Calling `thread.printStackTraceOfInterruptingThreads(System.out)` from the example above would show something like the following.


    java.lang.Thread.getStackTrace(Thread.java:1409)
       com.google.code.tempusfugit.concurrency.InterruptCapturingThread.interrupt(InterruptCapturingThread.java:61)
       com.google.code.tempusfugit.concurrency.InterruptCapturingThreadTest.interrupted(InterruptCapturingThreadTest.java:39)
       sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
       sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:39)
       sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:25)
       java.lang.reflect.Method.invoke(Method.java:585)
       org.junit.runners.model.FrameworkMethod$1.runReflectiveCall(FrameworkMethod.java:44)
       org.junit.internal.runners.model.ReflectiveCallable.run(ReflectiveCallable.java:15)
       org.junit.runners.model.FrameworkMethod.invokeExplosively(FrameworkMethod.java:41)
       org.junit.internal.runners.statements.InvokeMethod.evaluate(InvokeMethod.java:20)
       org.junit.internal.runners.statements.FailOnTimeout$1.run(FailOnTimeout.java:28)



[Next, Callables &raquo;](/documentation/callables/)