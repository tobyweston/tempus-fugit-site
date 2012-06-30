---
layout: post
title: "Detecting Deadlocks"
date: 2012-05-26 15:38
categories: [Concurrency]
comments: true
sidebar : false
keywords: "detecting deadlocks, find deadlocks, deadlocks, java, detect deadlocks programmatically, intrinsic and Java Lock deadlocks, tempus-fugit"
description: "Programmatically detect basic deadlocks in your Java code, both Java intrinsic (monitor) and Lock based cyclic problems."
---

The `DeadlockDetector` class allows you to programmatically detect basic deadlocks in your Java code. You can output deadlocks using the following code (note that printing a thread dump using the `ThreadDump` class will automatically attempt to find any deadlocks).

{% codeblock lang:java %}
DeadlockDetector.printDeadlocks(System.out);
{% endcodeblock %}


The `DeadlockDecector` class will spot Java monitor cyclic locking problems as well as `Lock` based cyclic problems. It's implementation is basically the same as that used by `jconsole` and `jstack`. The types of deadlock it can detect can be illustrated in the example below.

<!-- more -->

## Monitor Deadlock Example

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


[See this example in full](https://github.com/tobyweston/tempus-fugit/blob/0036345f047fb26b9ca20690895d458cc0c2e104/src/test/java/com/google/code/tempusfugit/concurrency/DeadlockDetectorTest.java)

## Lock Based Deadlock Example

{% codeblock lang:java %}
private final Cash cash = ... // Cash extends ReentrantLock
private final Cat = ... // Cat extends ReentrantLock

@Test
public void potentialDeadlock() throws InterruptedException {
    new Kidnapper().start();
    new Negotiator().start();
}

public class Kidnapper extends Thread {
    public void run() {
        try {
            keep(nibbles);
            take(cash);
        } finally {
            release(nibbles);
        }
    }
}

public class Negotiator extends Thread {
    public void run() {
        try {
            keep(cash);
            take(nibbles);
        } finally {
            release(cash);
        }
    }
}
{% endcodeblock %}

Where `keep`, `take` and `release` methods are pedagogically named methods wrapping the `Lock.lock` and `Lock.unlock` methods.

{% codeblock lang:java %}
private void keep(Lock lock) {
    lock.lock();
}

private void take(Lock lock) {
    lock.lock();
}

private void release(Lock lock) {
    lock.unlock();
}
{% endcodeblock %}


Same scenario as before, a deadlock ensues which is shown as.

    Deadlock detected
    =================

    "Negotiator-Thread-3":
      waiting to lock Monitor of java.util.concurrent.locks.ReentrantLock$NonfairSync@266bade9
      which is held by "Kidnapper-Thread-2"

    "Kidnapper-Thread-2":
      waiting to lock Monitor of java.util.concurrent.locks.ReentrantLock$NonfairSync@6766afb3
      which is held by "Negotiator-Thread-3"


[See this example in full](https://github.com/tobyweston/tempus-fugit/blob/728f90331f7281b2b2a7268ba58cdebbfdff3793/src/test/java/com/google/code/tempusfugit/concurrency/DeadlockDetectorWithLocksTest.java)
