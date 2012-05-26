---
layout: page
title: "Schedule Interruption (Wake a Sleeping Thread)"
date: 2012-05-25 19:49
comments: false
sharing: true
footer: false
sidebar: false
categories: [Thread Utilities]
---

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


[Next, Thread Utilities: Thread Dumps &raquo;](/documentation/threading/dumps)
