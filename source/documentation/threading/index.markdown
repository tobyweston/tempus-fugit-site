---
layout: page
title: "Thread Utilities"
date: 2012-05-20 20:33
comments: false
sharing: true
footer: false
indexer: true
categories: documentation
---

## Sleeping and Interruptions

Often, you'll see code like the example below

{% codeblock lang:java %}
try {
   Thread.sleep(100);
} catch (InterruptedException e) {
   // nothing
}
{% endcodeblock %}


tempus-fugit captures the annoying boiler plate code needed to reset the interrupt flat in situations where you can't or don't want to rethrow the `InterruptedException`.

Using the `ThreadUtils.sleep method`, the above code is rewritten as.

{% codeblock lang:java %}
sleep(millis(100));
{% endcodeblock %}


This ensures that the interrupt flag is reset and is more explicit about the [duration](time.html#Duration) of the sleep.

If you want to ensure the interrupt flag is reset for other code, you can use the `ThreadUtils.resetInterruptFlagWhen` method directly. The `Interruptible` interface is used to highlight that the lamda-like call you want to execute does in fact throw the `InterruptedException`. For example;

{% codeblock lang:java %}
resetInterruptFlagWhen(new Interruptible<Void>() {
    public Void call() throws InterruptedException {
        Thread.sleep(100);
        return null;
    }
});
{% endcodeblock %}

Extracting the lamda-like `Interruptible` to a method makes the code more expressive;

{% codeblock lang:java %}
resetInterruptFlagWhen(sleepingIsInterrupted());
{% endcodeblock %}

This is actually how the `ThreadUtils.sleep` method is implemented within tempus-fugit.

## Scheduled Interruption

The `Interrupter` class allows you to schedule an `interrupt` on a thread after a specified duration. This can be useful when implementing timeouts on classes that support the use of `interrupt` as an interruption policy. For example, the code below sets up an interrupt to be scheduled after some timeout, before embarking on some potentially long running process. The `Interrupter` and `Thread` classes have been statically imported.


{% codeblock lang:java %}
Interrupter interrupter = interrupt(currentThread()).after(timeout);
try {
    while (!currentThread().isInterrupted()) {
        // some long running process
    }
} finally {
    interrupter.cancel();
}
{% endcodeblock %}

The `Interrupter` spawns a thread which sleeps (using `WaitFor`) until the timeout expires. It then just calls `interrupt` on the passed in thread. It is important therefore to ensure you cancel the interrupt as above for the case when the long running process could finish before the timeout. The `cancel` has no affect if the timeout has already expired so using a `finally` block is recommended.

The `DefaultTimeoutableCompletionService` classes uses this approach to implement a `java.util.concurrent.CompletionService`-like service that will timeout and return any completed tasks and abandoning any remaining.

## Thread Dumps

The `ThreadDump` class offers a programmatic way to print a thread dump. It's not recommended for production code but can be handy in tracking down unexpected behaviour interactively. Using `ThreadDump.dumpThreads(System.out)`, for example, would yield something like the following (formatting inspired by `jstack`).



     Thread Reference Handler@2: (state = WAITING)
     - java.lang.Object.wait(Native Method)
     - java.lang.Object.wait(Object.java:474)
     - java.lang.ref.Reference$ReferenceHandler.run(Reference.java:116)

    Thread main@1: (state = RUNNABLE)
     - java.lang.Thread.dumpThreads(Native Method)
     - java.lang.Thread.getAllStackTraces(Thread.java:1460)
     - com.google.code.tempusfugit.concurrency.ThreadDump.dumpThreads(ThreadDump.java:25)
      ...
     - com.intellij.rt.execution.junit.JUnitStarter.prepareStreamsAndStart(JUnitStarter.java:118)
     - com.intellij.rt.execution.junit.JUnitStarter.main(JUnitStarter.java:40)

    Thread Signal Dispatcher@4: (state = RUNNABLE)

    Thread Finalizer@3: (state = WAITING)
     - java.lang.Object.wait(Native Method)
     - java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:120)
     - java.lang.ref.ReferenceQueue.remove(ReferenceQueue.java:136)
     - java.lang.ref.Finalizer$FinalizerThread.run(Finalizer.java:159)


The `dumpThreads` method will also detect any Java-level deadlocks, see the Deadlock Detection section for details.

## Deadlock Detection

The `DeadlockDetector` class allows you to programmatically detect basic deadlocks in your Java code. You can output deadlocks using the following code (note that printing a thread dump using the `ThreadDump` class will automatically attempt to find any deadlocks).

{% codeblock lang:java %}
DeadlockDetector.printDeadlocks(System.out);
{% endcodeblock %}

There are various types of deadlock in concurrent systems, broadly speaking with regard to Java, they can be categorised as

  * Java monitor cyclic locking dependency
  * Java `Lock` cyclic locking dependency
  * External resource based dependency
  * Live lock

The `DeadlockDecector` class can only spot Java monitor cyclic locking problems. It's implementation is basically the same as that used by `jconsole` and `jstack` and suffers the same limitations. Java 1.6 versions of `jstack` and `jconsole` can additionally detect `Lock` based cyclic problems. The types of deadlock it can detect can be illustrated in the example below.



{% codeblock lang:java %}
 public void potentialDeadlock() {
     new Kidnapper().start();
     new Negotiator().start();
 }

 public class Kidnapper extends Thread {
     public void run() {
         synchronized (nibbles) {
             synchronized (cash) {
                 take(cash);
             }
         }
     }
 }

 public class Negotiator extends Thread {
     public void run() {
         synchronized (cash) {
             synchronized (nibbles) {
                 take(nibbles);
             }
         }
     }
 }
{% endcodeblock %}


Here, the `Kidnapper` is unwilling to release poor Nibbles the `Cat` until he has the `Cash` but our `Negotiator` is unwilling to part with the `Cash` until he has poor Nibbles back in his arms. The deadlock detector displays this woeful situation as follows.



    Deadlock detected
    =================

    "Negotiator-Thread-1":
      waiting to lock Monitor of com.google.code.tempusfugit.concurrency.DeadlockDetectorTest$Cat@ce4a8a
      which is held by "Kidnapper-Thread-0"

    "Kidnapper-Thread-0":
      waiting to lock Monitor of com.google.code.tempusfugit.concurrency.DeadlockDetectorTest$Cash@7fc8b2
      which is held by "Negotiator-Thread-1"


## Miscellaneous

### Wait for a Thread to be in a State

The `Conditions` class offers some thread related `Condition`s including the following.

  * `Conditions.isWaiting(Thread thread)`

The static method `Conditions.isWaiting(Thread)` offers a Condition that allows you to test if a thread is in a waiting state. Combining the condition with some classes from the [temporal](time.html#Conditions_and_Waiting) package allows you to wait for a thread to be in the waiting state. For example,


{% codeblock lang:java %}
waitOrTimeout(isWaiting(thread), timeout(seconds(10)));
{% endcodeblock %}


  * `Conditions.is(Thread thread, Thread.State state)`

The static method `Conditions.is(Thread, ThreadState)` offers a more general purpose `Condition` to check that a thread is in a given state. For example,


{% codeblock lang:java %}
waitOrTimeout(is(thread, TERMINATED), timeout(seconds(10)));
{% endcodeblock %}


  * `Conditions.isAlive(Thread thread)`

The static method `Conditions.isAlive(Thread` will check that a thread is alive. A thread is alive if it has been started and has not yet died. For example,


{% codeblock lang:java %}
System.out.println(isAlive(Thread.currentThread()));
{% endcodeblock %}


### Wait for an Executor to Shutdown

  * `Conditions.shutdown(ExecutorService service)`

This method will check that a `java.util.concurrent.ExecutorService` has been shutdown according to the result of the it's `isShutdown` method. This might be useful if you'd like to wait for shutdown. The tempus-fugit `ExecutorServiceShutdown` class does just this.


{% codeblock lang:java %}
waitOrTimeout(Conditions.shutdown(executor), timeout);
{% endcodeblock %}



### Invert a Condition

  * `Conditions.not(Condition condition)`

The `NotCondition` will negate the logical result of some other condition. For example, we can change the example above to wait until a thread is _not_ in a waiting state by using the following.


{% codeblock lang:java %}
waitOrTimeout(not(isWaiting(thread)), timeout(seconds(10)));
{% endcodeblock %}


### Wrap Exceptions as Another Type

  * Not exclusively for concurrent use, the `ExceptionWrapper` class allows you to run arbitrary code in a `Callable` block catching any `Throwable` as an exception of your choice, embedded the originating exception as the new exception's `cause`. For example,


{% codeblock lang:java %}
ExceptionWrapper.wrapAnyException(new Callable<Object>() {
    @Override
    public Object call() throws ServiceException {
        // nasty code throwing a bunch of exceptions
    }
}, WithException.with(CalendarException.class));
{% endcodeblock %}


You can also catch any `Exception` and rethrow as a `RuntimeException` with the originating exception as the `cause`. The example below shows the anonymous `Callable` being created in the method `something`.


{% codeblock lang:java %}
ExceptionWrapper.wrapAsRuntimeException(something());
{% endcodeblock %}


### A Default Thread Factory

  * As a convenience class, the `DefaultThreadFactory` offers an implementation of `java.util.concurrent.ThreadFactory` that creates a thread using the single argument constructor of `Thread`.


[Next, Concurrency Utilities &raquo;](/documentation/concurrency/)

