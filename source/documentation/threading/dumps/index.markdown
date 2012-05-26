---
layout: page
title: "Thread Dumps"
date: 2012-05-25 19:43
sharing: true
comments: false
footer: false
sidebar: false
categories: [Thread Utilities]
---

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


The `dumpThreads` method will also detect any Java-level deadlocks, see the next section for details.



[Next, Thread Utilities: Deadlock Detection &raquo;](/documentation/threading/deadlock)
