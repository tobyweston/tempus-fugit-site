---
layout: page
title: "Callables"
date: 2012-05-20 20:33
comments: false
sharing: true
footer: false
categories: documentation
indexer: true
---

## Callable Adapter

The `java.util.concurrent.Executors` class has helper methods to convert from a `Runnable` to a `Callable` but lacks a counterpart to convert a `Callable` to a `Runnable`. This is presumably because a `Runnable` lacks the ability to throw exceptions or return values.

Both `Runnable` and `Callable` are handy interfaces to express lamda-like functionality in Java. Discounting their close relationship to concurrency mechanisms in Java, they both really just represent something that can be called. Choosing between the two, the `Callable` is more powerful.

The `CallableAdapter` class will convert from a `Callable` into a `Runnable` wrapping any exception as a `RuntimeException` and discarding any return type. This allows you to write general task code in the form of a `Callable` without necessarily being hampered if you need to pass in a `Runnable` to some framework code.

As a concrete example, Java's `ScheduledExecutorService` class doesn't allow you to schedule a task with a fixed delay or at a fixed rate. The interface takes a `Runnable`. However, using the adapter you can schedule a `Callable` at a fixed rate (ignoring the result). The underlying `Callable` task could then be used elsewhere where the result is actually used.

## tempus-fugit Callable

The tempus-fugit `Callable` interface extends `java.util.concurrent.Callable` but allows you to specify the exception as a generic type. This class has a fairly limited usage and isn't recommended over the standard Java version. Instead, if you create a method that takes a `java.util.concurrent.Callable` as a argument, calling it will force the method to throw `Exception`. If instead, you pass in a `com.google.code.tempusfugit.concurrency.Callable`, you can specify the specific exception to throw and therefore avoid being forced to throw `Exception`. For example


{% codeblock lang:java %}
public <T> T foo(java.util.concurrent.Callable<T> callable) throws **Exception** {
    return callable.call();
}
{% endcodeblock %}

Whereas using the tempus-fugit version allows a more specific exception to be thrown.


{% codeblock lang:java %}
public <T> T bar(com.google.code.tempusfugit.concurrency.Callable<T, RuntimeException> callable) {
    return callable.call();
}
{% endcodeblock %}

[Next, Testing Time Sensitive Code &raquo;](/documentation/time/)