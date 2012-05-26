---
layout: page
title: "Running Tests in Parallel"
date: 2012-05-26 17:13
sharing: true
comments: false
footer: false
sidebar: false
categories: [JUnit Integration]
---

With tempus-fugit, you can easily run tests methods in parallel. Each test method within a class will run on its own thread and in parallel with any other test methods in that class. So, the number of threads for a given test class will be equal to the number of test methods within that class.

Simply mark your test to be `@RunWith` the `ConcurrentTestRunner` class as below.

{% codeblock lang:java %}
@RunWith(ConcurrentTestRunner.class)
public class ConcurrentTestRunnerTest {

    @Test
    public void shouldRunInParallel1() {
        System.out.println("I'm running on thread " + Thread.currentThread().getName());
    }

    @Test
    public void shouldRunInParallel2() {
        System.out.println("I'm running on thread " + Thread.currentThread().getName());
    }

    @Test
    public void shouldRunInParallel3() {
        System.out.println("I'm running on thread " + Thread.currentThread().getName());
    }
}
{% endcodeblock %}

In this example, each of the individual test methods are run once but in their own thread, all spawned roughly at the same time. The output from the above might look like the following.

    I'm running on thread ConcurrentTestRunner-Thread-0
    I'm running on thread ConcurrentTestRunner-Thread-2
    I'm running on thread ConcurrentTestRunner-Thread-1

Another run might yield a different interpolation.

    I'm running on thread ConcurrentTestRunner-Thread-1
    I'm running on thread ConcurrentTestRunner-Thread-0
    I'm running on thread ConcurrentTestRunner-Thread-2



[Next, JUnit Integration: Load / Soak Tests &raquo;](/documentation/junit/load/)