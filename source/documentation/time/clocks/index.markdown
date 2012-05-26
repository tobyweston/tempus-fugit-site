---
layout: page
title: "Testing with the Clock Interface"
date: 2012-05-26 17:52
comments: false
sharing: true
footer: false
sidebar: false
categories: [Time Sensitive Code]
---

The `Clock` interface along with its default implementation `DefaultClock` are aimed at making testing classes that require a date easier. Rather than pass around `java.util.Date` classes which will return the current date when constructed, you can pass around a factory which allows you to control the date.

For example, the `StopWatch` class maintains an internal `Date` which it can use to compare with the current time to work out the elapsed time. A straight forward implementation might look like this


{% codeblock lang:java %}
public class BadStopWatch {

    private Date startDate;
    private long elapsedTime;

    public BadStopWatch() {
        this.startDate = new Date();
    }

    public Duration getElapsedTime() {
        return millis(new Date().getTime() - startDate.getTime());
    }
}
{% endcodeblock %}


Writing the (rather silly) test below highlights a problem using real time in the class.


{% codeblock lang:java %}
public class BadStopWatchTest {
    @Test
    public void getElapsedTime() {
        BadStopWatch watch = new BadStopWatch();
        ThreadUtils.sleep(millis(100));
        assertThat(watch.getElapsedTime(), is(millis(100)));
    }
 }
{% endcodeblock %}


The test is unlikely to pass!


    java.lang.AssertionError:
    Expected: is <Duration 100 MILLISECONDS>
         got: <Duration 103 MILLISECONDS>
    	at org.junit.Assert.assertThat(Assert.java:778)
    	at org.junit.Assert.assertThat(Assert.java:736)
    	at com.google.code.tempusfugit.temporal.BadStopWatchTest.getElapsedTime(BadStopWatchTest.java:32)

Whereas, if we write the class using a controllable time, we can write a more deterministic test. Here, we create an alternative stop watch implementation and mock the factory using [JMock](http://www.jmock.org/).



{% codeblock lang:java %}
public class BetterStopWatch {

    private Date startDate;
    private long elapsedTime;
    private Clock clock;

    public BetterStopWatch(Clock clock) {
        this.clock = clock;
        this.startDate = clock.now();
    }

    public Duration getElapsedTime() {
        return millis(clock.now().getTime() - startDate.getTime());
    }
}
{% endcodeblock %}


The test becomes clearer

{% assign braces = '{{' %}
{% codeblock lang:java %}
@Test
public void getElapsedTimeFromBetterStopWatch() {
    context.checking(new Expectations() {{ braces }}
        one(clock).now(); will(returnValue(new Date(0)));
        one(clock).now(); will(returnValue(new Date(100)));
    }});
    BetterStopWatch watch = new BetterStopWatch(time);
    assertThat(watch.getElapsedTime(), is(millis(100)));
}
{% endcodeblock %}



## Movable Clock

You can use the `MovableClock` in tests to explicitly move time forward within the context of a test. For example, we can rewrite the test above as follows.



{% codeblock lang:java %}
@Test
public void getElapsedTimeUsingMovableClock() {
    MovableClock clock = new MovableClock();
    BetterStopWatch watch = new BetterStopWatch(clock);
    assertThat(watch.getElapsedTime(), is(millis(0)));
    clock.incrementBy(millis(100));
    assertThat(watch.getElapsedTime(), is(millis(100)));
}
{% endcodeblock %}


## Stop Watches

The `StopWatch` class allows you to record the length of time taken between starting and stopping the watch. It's used internally with the `WaitFor.waitUntil(Timeout timeout, ...)` class.


[Next, Annotations &raquo;](/documentation/annotations)