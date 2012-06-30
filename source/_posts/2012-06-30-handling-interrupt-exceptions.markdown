---
layout: post
title: "Handling Interrupt Exceptions"
date: 2012-06-30 13:01
comments: true
categories: [Concurrency]
sidebar: false
keywords: "Thread.interrupt, Java concurrency, interrupt, InterruptedException, java.lang"
description: "Learn how should you handle InterruptedExceptions"
---

How should you handle `InterruptedException`s?

{% codeblock lang:java %}
try {
    Thread.sleep(100);
} catch (InterruptedException e) {
    // what to do?
}
{% endcodeblock %}

<!-- more -->

You could rethrow if it's appropriate but often its not. If that's the case, you should set the _interrupt status_ flag associated with the current thread. For example,

{% codeblock lang:java %}
try {
    Thread.sleep(100);
} catch (InterruptedException e) {
    Thread.currentThread().interrupt(); // reset the interrupt status
}
{% endcodeblock %}

Typically, if a Java method throws `InterruptedException`, it will have reset the _interrupt status_ before doing so. In the example above, you're just restoring it and preserving a flag to indicate the thread had once been interrupted.

The reason for preserving this status flag is in case code other than your own depends on it. For example, a framework (which you may not appreciate is actually being used), may be doing something like the following to (correctly) support interruption.

{% codeblock lang:java %}
while (!Thread.currentThread().isInterrupted()) {
    process();
}{% endcodeblock %}


You should generally never just catch the exception and ignore it; it may cripple code depending on the status flag for correct behaviour. In the same way, it's rarely a good idea to catch and exception and [just log it](http://baddotrobot.com/blog/2010/10/18/logging-is-evil-but/), especially in the case of `InterruptedException`.

