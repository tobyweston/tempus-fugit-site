---
layout: page
title: "Callable with Exception Generics"
date: 2012-05-26 17:27
sharing: true
comments: false
footer: false
sidebar: false
categories: [Callables]
---

The tempus-fugit `Callable` interface extends `java.util.concurrent.Callable` but allows you to specify the exception as a generic type. This class has a fairly limited usage and isn't recommended over the standard Java version. Instead, if you create a method that takes a `java.util.concurrent.Callable` as a argument, calling it will force the method to throw `Exception`. If instead, you pass in a `com.google.code.tempusfugit.concurrency.Callable`, you can specify the specific exception to throw and therefore avoid being forced to throw `Exception`. For example


{% codeblock lang:java %}
public <T> T foo(java.util.concurrent.Callable<T> callable) throws Exception {
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