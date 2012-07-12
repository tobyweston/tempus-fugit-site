---
layout: page
title: "Convert Callable to Runnable"
date: 2012-05-26 17:27
sharing: true
comments: false
footer: false
sidebar: false
categories: [Callables]
---

The `java.util.concurrent.Executors` class has helper methods to convert from a `Runnable` to a `Callable` but lacks a counterpart to convert a `Callable` to a `Runnable`. This is presumably because a `Runnable` lacks the ability to throw exceptions or return values.

Both `Runnable` and `Callable` are handy interfaces to express lamda-like functionality in Java. Discounting their close relationship to concurrency mechanisms in Java, they both really just represent something that can be called. Choosing between the two, the `Callable` is more powerful.

The `CallableAdapter` class will convert from a `Callable` into a `Runnable` wrapping any exception as a `RuntimeException` and discarding any return type. This allows you to write general task code in the form of a `Callable` without necessarily being hampered if you need to pass in a `Runnable` to some framework code.

As a concrete example, Java's `ScheduledExecutorService` class doesn't allow you to schedule a task with a fixed delay or at a fixed rate. The interface takes a `Runnable`. However, using the adapter you can schedule a `Callable` at a fixed rate (ignoring the result). The underlying `Callable` task could then be used elsewhere where the result is actually used.



[Next, Callables: Callable with Exception Generics &raquo;](/documentation/callables/custom/)