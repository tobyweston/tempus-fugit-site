---
layout: post
title: "Wait for UI Elements in Tests"
date: 2013-03-17 14:56
comments: true
categories: [Concurrency, Testing]
sidebar: false
published: true
keywords: "java, tempus-fugit, probe, waitFor, UI, selenium, webdriver"
description: "Easily wait for UI elements in a specific state when testing. Wait for a condition and timeout or simulate a JUnit failure if an assertion never matches."
---

When a UI asynchronously updates a value, it can be difficult to make assertions in tests reliably. There are typically two approaches to solving this, either poll the UI until the value matches the assertion (timing out after a certain amount of time) or make the UI notify your test code that a value has changed.

Using the `WaitFor` class along with [Web Driver](http://docs.seleniumhq.org/docs/03_webdriver.jsp#) allows you to do the former with something like this.

<!-- more -->

## Wait for a Condition

{% codeblock lang:java %}
WaitFor.waitOrTimeout(new Condition() {
    @Override
    public boolean isSatisfied() {
        return ui.findElement(By.id("result")).getText().equals("100 matches");
    }
}, timeout(millis(250)))
{% endcodeblock %}


This creates an implicit assertion. If the `Condition` returns `true` after any number of attempts, the test code continues without incident. If, however, it doesn't find the value within the timeout, a `TimeoutException` will be thrown failing your test.


## Wait for an Assertion

In [tempus-fugit 1.2](https://oss.sonatype.org/content/repositories/snapshots/com/google/code/tempus-fugit/tempus-fugit/1.2-SNAPSHOT/), there's a new method on `WaitFor` to convert the `TimeoutException` above into a JUnit failure.

{% codeblock lang:java %}
public static void waitFor(SelfDescribingCondition condition, Timeout timeout) throws InterruptedException {
    waitOrTimeout(condition, failOnTimeout(condition), timeout);
}
{% endcodeblock %}

Combine it with `Conditions.assertion` to periodically query the UI and compare it against a Hamcrest `Matcher`. For example,

{% codeblock lang:java %}
waitFor(assertion(getResultFrom(ui), is("100 matches")), timeout(millis(250)));
{% endcodeblock %}

where, `getResultFrom(ui)` returns an instance of `ProbeFor<T>` (a self describing `Callable` used to query the UI for a `T`).

{% codeblock lang:java %}
public static ProbeFor<String> getResultFrom(final UI ui) {
    return new ProbeFor<String>() {
        @Override
        public String call() throws RuntimeException {
            return ui.findElement(By.id("result")).getText();
        }

        @Override
        public void describeTo(Description description) {
            description.appendText("'number of results' field in the UI");
        }
    };
}
{% endcodeblock %}


## Turn Timeouts into AssertionErrors

Now rather than fail with a `TimeoutException`, if the assertion hasn't matched before the timeout expires, a regular JUnit failure (`AssertionError`) will be thrown. In the IDE, it'll look something like this.

    java.lang.AssertionError: 'number of results' field in the UI
    Expected: is "100 matches"
         but: <was "">, <was "">, <was "">, <was "">, <was "200 matches">


The `describeTo` method describes the probe and the `Matcher` describes what was expected. Because the UI was polled several times, each value was displayed in the 'but was' section. On the fifth attempt, a value was found but it didn't match the expectation.