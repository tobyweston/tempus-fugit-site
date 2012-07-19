---
layout: page
title: "Load / Soak Tests"
date: 2012-05-26 17:15
sharing: true
comments: false
footer: false
sidebar: false
categories: [JUnit Integration]
---

The tempus-fugit library offers a `RepeatingRule` and `ConcurrentRule` that can be used to run a test method multiple times and across multiple threads. This can be useful when writing load or soak tests. For example, you might want to sanity check that your synchronisation is working under load. Both rules work use an annotation and can be used independently or together.

To run multiple instances of a single test method in parallel, you annotate the test method with the associated `Concurrent` annotation and declare the rule in your test class. For example, you might test the `AtomicInteger` class in a similar way to this.


{% codeblock lang:java %}
public class RunConcurrentlyTest {

    @Rule public ConcurrentRule rule = new ConcurrentRule();

    private static final AtomicInteger counter = new AtomicInteger();

    @Test
    @Concurrent (count = 5)
    public void runsMultipleTimes() {
        counter.getAndIncrement();
    }
 }
{% endcodeblock %}

Here, the test method is run in parallel across five threads which may or may not expose potential threading issues. It's not recommended you use this as your only concurrent testing strategy but it may occasionally find a use.

To run a test method multiple times, you can take advantage of the `Repeating` annotation and declare the rule in your test class. This is similar to using the `Intermittent` annotation but unlike using the `@RunWith` mechanism, using the `Rule` will _not_ execute any `@Before` or `@After` methods between runs. Using `Repeating` is also more explicit that you intend to run some kind of load test rather than indicating that a test is intermittently failing.



{% codeblock lang:java %}
public class RepeatingRuleTest {

    @Rule public RepeatingRule rule = new RepeatingRule();

    private static int counter = 0;

    @Test
    @Repeating(repetition = 99)
    public void annotatedTest() {
        counter++;
    }

    @After
    public void annotatedTestRunsMultipleTimes() {
        assertThat(counter, is(99));
    }
}
{% endcodeblock %}

Combining the `Concurrent` with the `Repeating` annotation allows you to run a test method repeatedly and across threads. For example, running the following


{% codeblock lang:java %}
public class RunConcurrentlyTest {

    @Rule public ConcurrentRule concurrently = new ConcurrentRule();
    @Rule public RepeatingRule repeatedly = new RepeatingRule();

    private static final AtomicInteger counter = new AtomicInteger();

    @Test
    @Concurrent (count = 5)
    @Repeating (repetition = 10)
    public void runsMultipleTimes() {
        counter.getAndIncrement();
    }
 }
{% endcodeblock %}

Will repeat the test method ten times in five threads. Each thread will run the test method ten times, so in our example, the counter will be incremented to fifty.


[Next, JUnit Integration: Waiting for Assertions &raquo;](/documentation/junit/waiting/)