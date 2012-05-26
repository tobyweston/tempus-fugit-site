---
layout: page
title: "Waiting for Assertions"
date: 2012-05-26 17:16
sharing: true
comments: false
footer: false
sidebar: false
categories: [JUnit Integration]
---

The `WaitFor` class can be used to wait for a condition to hold. You can use it within your tests to wait for some asynchronous process to complete and so make an assertion in a test.

In the example below, a test verifies that the action of clicking a button will toggle some switch to a different position. However, this test may or may not pass if the `clickButton()` kicks off an asynchronous process to update the toggle position. It may return immediately having not yet changed the position.



{% codeblock lang:java %}
@Test
public void toggleButton() {
    assertThat(toggle, is(ON));
    clickButton();
    assertThat(toggle, is(OFF));
}
{% endcodeblock %}

Rewriting the test using a `WaitFor` would look like this


{% codeblock lang:java %}
@Test
public void toggleButton() throws TimeoutException {
    assertThat(toggle, is(ON));
    clickButton();
    waitOrTimeout(new Condition() {
        public boolean isSatisfied() {
            return toggle == OFF;
        }
    }, seconds(5));
}
{% endcodeblock %}

Here, the test will retry the `Condition` for five seconds before finally giving up and failing the test. If the condition is true immediately, the wait will continue immediately and the test will continue. By extracting a method to create the `Condition`, you can further refactor the test to be more expressive and start to create a library of reusable conditions.


{% codeblock lang:java %}
@Test
public void toggleButton() throws TimeoutException {
    assertThat(toggle, is(ON));
    clickButton();
    waitOrTimeout(toggleIs(OFF), seconds(5));
}
...
private Condition toggleIs(final Position position) {
    return new Condition() {
        public boolean isSatisfied() {
            return toggle == position;
        }
    };
}
{% endcodeblock %}


A wait which times out will through a `TimeoutException` although, since 1.2, you can also supply the `waitOrTimeout` call with behaviour to execute on timeout (as a `Callable`). For example;


{% codeblock lang:java %}
waitOrTimeout(serverIsShutdown(), new Callable<Void, RuntimeException>() {
    @Override
    public Void call() throws RuntimeException {
        notifyObservers(new FailedToShutdownEvent());
        return null;
    }
}, timeout(millis(500)));
{% endcodeblock %}


will not throw a `TimeoutException` but instead notify some observer of the failure. Refactored a little, it would look like this


{% codeblock lang:java %}
waitOrTimeout(serverIsShutdown(), notifyFailureOnTimeout(), timeout(millis(500)));
...
private Callable<Void, RuntimeException> notifyFailureOnTimeout() {
    return new Callable<Void, RuntimeException>() {
        @Override
        public Void call() throws RuntimeException {
            notifyObservers(new FailedToShutdownEvent());
            return null;
        }
    }
}
{% endcodeblock %}



[Next, JUnit Integration: Testing Interrupts &raquo;](/documentation/junit/interrupt/)