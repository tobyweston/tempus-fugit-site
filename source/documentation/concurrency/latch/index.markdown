---
layout: page
title: "Countdown Latch with Timeout"
date: 2012-05-26 16:52
sharing: true
comments: false
footer: false
sidebar: false
categories: [Concurrency Utilities]
---

Using an instance of a `java.util.concurrent.CountDownLatch`, we can wait for a latch to count down to zero, blocking the calling thread before continuing. When passing in a timeout, the method returns `true` if the count reached zero or false if the timeout expires.

To make the timeout more explicit, the `CountDownLatchWithTimeout` class will throw a `TimeoutException` rather than force you to check. Using a static import, the example looks like the following.


{% codeblock lang:java %}
private final CountDownLatch startup = new CountDownLatch(1);

public void waitForStartup() throws InterruptedException, TimeoutException {
    await(startup).with(TIMEOUT);
}
{% endcodeblock %}

The use of the `with` method is required. Following the [micro- DSL](http://baddotrobot.com/blog/2009/02/16/more-on-micro-dsls/) approach, it is the `with` that actually does the waiting. Calling the `await` method on it's own will not block.


[Next, Concurrency Utilities: Always Execute Using Locks &raquo;](/documentation/concurrency/locks)
