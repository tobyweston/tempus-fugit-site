---
layout: page
title: "Conditions"
date: 2012-05-26 17:45
comments: false
sharing: true
footer: false
sidebar: false
categories: [Time Sensitive Code]
---

Conditions are part of our everyday language. The `Condition` interface captures a conditional as something that can be reused. For example, waiting for something can be achieved using the `WaitFor` (see [waiting](/documentation/time/waiting)) class and an anonymous `Condition`. For example,


{% codeblock lang:java %}
private void waitForShutdown() throws TimeoutException {
    waitOrTimeout(new Condition() {
        public boolean isSatisfied() {
            return server.isShutdown();
        }
    }, timeout);
 }
{% endcodeblock %}


will wait for some `server` to indicate that it has shutdown. The `Conditions` class collects useful `Condition` objects such as `not`. There is also a useful `Condition` to indicate if a thread is in a waiting state in `ThreadUtils`.

Some common thread related conditions have been collected in the `Conditions` class. These include a _not_ condition to invert the result of some other condition and various thread state related conditions such as checking if a a thread alive. See the [miscellaneous thread utils](/documentation/threading/misc) section for details.

For testing purposes, you might want to assert against the outcome of a `Condition`. The `Conditions` class has an `assertThat` method which takes a `Matcher<Boolean>` for use with JUnit. For example, you could assert against a condition using vanilla JUnit like this.


{% codeblock lang:java %}
Assert.assertThat(not(TRUE).isSatisfied(), is(false));
{% endcodeblock %}


or using the `Conditions` class, you can tidy the assert up to look like this.


{% codeblock lang:java %}
Conditions.assertThat(not(TRUE), is(false));
{% endcodeblock %}


If you have `Matcher`s available in your production code, you can use this with flexible waits, for example,


{% codeblock lang:java %}
WaitFor.waitOrTimeout(Conditions.assertion("hello", is(not(equalTo("goodbye")))), timeout(millis(100)));
{% endcodeblock %}


[Next, Testing Time Sensitive Code: Waiting For Conditions &raquo;](/documentation/time/waiting)