---
layout: post
title: "Detecting Deadlocks"
date: 2012-05-26 15:38
categories: [Concurrency]
comments: true
sidebar : false
---

The `DeadlockDetector` class allows you to programmatically detect basic deadlocks in your Java code. You can output deadlocks using the following code (note that printing a thread dump using the `ThreadDump` class will automatically attempt to find any deadlocks).

{% codeblock lang:java %}
DeadlockDetector.printDeadlocks(System.out);
{% endcodeblock %}


The `DeadlockDecector` class will spot Java monitor cyclic locking problems as well as `Lock` based cyclic problems. It's implementation is basically the same as that used by `jconsole` and `jstack`. The types of deadlock it can detect can be illustrated in the example below.

<!-- more -->

## Monitor Deadlock

{% codeblock lang:java %}
@Test
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


Here, the Kidnapper is unwilling to release poor Nibbles the Cat until he has the Cash but our Negotiator is unwilling to part with the Cash until he has poor Nibbles. The deadlock detector displays this situation as follows.



     Deadlock detected
     =================

     "Negotiator-Thread-1":
        waiting to lock Monitor of ...DeadlockDetectorTest$Cat@ce4a8a
        which is held by "Kidnapper-Thread-0"

     "Kidnapper-Thread-0":
        waiting to lock Monitor of ...DeadlockDetectorTest$Cash@7fc8b2
        which is held by "Negotiator-Thread-1"



## Lock Deadlock

