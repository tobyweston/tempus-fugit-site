---
layout: page
title: "Waiting for Conditions"
date: 2012-05-26 17:45
comments: false
sharing: true
footer: false
sidebar: false
categories: [Time Sensitive Code]
---

The `WaitFor` class can be used to periodically check if a `Condition` is satisfied, sleeping for a short period if it has not before checking again. The methods available are

  * `waitOrTimeout`
  * `waitUntil`

The `waitOrTimeout` will wait until the condition is satisfied or timeout after a specified `Timeout`. The `waitUntil` waits until a given timeout without checking against any condition. Both methods can be interrupted and so throw an `InterruptedException`. The sleep period between condition checks is defaulted but since version 1.1 can be overridden (by passing in a implementation of `Sleeper` such as `ThreadSleeper`) .

For example, waiting for a thread to move into a waiting state can be implemented like this;

{% codeblock lang:java %}
private void waitForStartup(final Thread thread) throws TimeoutException, InterruptedException {
    waitOrTimeout(new Condition() {
        public boolean isSatisfied() {
            return (thread.getState() == TIMED_WAITING) || (thread.getState() == WAITING);
        }
    }, timeout(seconds(10)));
}
{% endcodeblock %}

Where `WaitFor.waitOrTimeout` has been statically imported and `Timeout.timeout` is a static constructor for a `Timeout` object.

A call to `waitOrTimeout` will also throw a `TimeoutException` if it times out. However, you can call an overloaded version which doesn't throw the exception but instead executes some behaviour you pass in via a `Callable` instance. For example,


{% codeblock lang:java %}
private void waitForStartup(final Thread thread) throws InterruptedException {
    waitOrTimeout(threadStarted(thread), new Callable() {
        public Void call() throws RuntimeException {
            notifyObservers(new FailedToStart(thread));
            return null;
        }
    }, timeout(seconds(10)));
}
{% endcodeblock %}



[Next, Testing Time Sensitive Code: Timeouts &raquo;](/documentation/time/timeouts)

