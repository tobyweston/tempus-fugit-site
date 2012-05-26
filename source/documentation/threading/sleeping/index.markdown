---
layout: page
title: "Sleeping and Interruptions"
date: 2012-05-25 19:41
comments: false
sharing: true
footer: false
sidebar: false
categories: documentation
---

Often, you'll see code like the example below

{% codeblock lang:java %}
try {
   Thread.sleep(100);
} catch (InterruptedException e) {
   // nothing
}
{% endcodeblock %}


tempus-fugit captures the annoying boiler plate code needed to reset the interrupt flat in situations where you can't or don't want to rethrow the `InterruptedException`.

Using the `ThreadUtils.sleep method`, the above code is rewritten as.

{% codeblock lang:java %}
sleep(millis(100));
{% endcodeblock %}


This ensures that the interrupt flag is reset and is more explicit about the [duration](time.html#Duration) of the sleep.

If you want to ensure the interrupt flag is reset for other code, you can use the `ThreadUtils.resetInterruptFlagWhen` method directly. The `Interruptible` interface is used to highlight that the lamda-like call you want to execute does in fact throw the `InterruptedException`. For example;

{% codeblock lang:java %}
resetInterruptFlagWhen(new Interruptible<Void>() {
    public Void call() throws InterruptedException {
        Thread.sleep(100);
        return null;
    }
});
{% endcodeblock %}

Extracting the lamda-like `Interruptible` to a method makes the code more expressive;

{% codeblock lang:java %}
resetInterruptFlagWhen(sleepingIsInterrupted());
{% endcodeblock %}

This is actually how the `ThreadUtils.sleep` method is implemented within tempus-fugit.




[Next, Thread Utilities: Scheduled Interruption &raquo;](/documentation/threading/wakeup)
