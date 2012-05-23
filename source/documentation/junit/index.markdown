---
layout: page
title: "JUnit Integration"
date: 2012-05-20 20:33
comments: false
sharing: true
footer: false
categories: documentation
indexer: true
---

### Intermittent Tests

As much as possible, you aim to have a completely deterministic tests but despite your best efforts, the odd flickering test can still get through. Occasionally, you might want to run such a test repeatedly to get an idea of its indeterminacy. The `Intermittent` annotation can be combined with the `IntermittentTestRunner` to provide this behaviour along side [junit](http://junit.org/).

You simply mark a junit test method (or class) as potentially intermittent using the `Intermittent` annotation as follows.


{% codeblock lang:java %}
@Test
@Intermittent
public void flickering() {
   // ...
}
{% endcodeblock %}


You can then use the `@RunWith` annotation to run the test using the `IntermittentTestRunner`. Any `@Before` or `@After` methods will be run once for each test repetition. The example below also shows that the repetition count can be overridden on the method annotation.


{% codeblock lang:java %}
@RunWith(IntermittentTestRunner.class)
public class IntermittentTestRunnerTest {

    private static int testCounter = 0;
    private static int afterCounter = 0;
    private static int afterClassCounter = 0;

    @Test
    @Intermittent(repetition = 99)
    public void annotatedTest() {
        testCounter++;
    }

    @After
    public void assertAfterIsCalledRepeatedlyForAnnotatedTests() {
        assertThat(testCounter, is(equalTo(++afterCounter)));
    }

    @AfterClass
    public static void assertAfterClassIsCalledOnce() {
        assertThat(++afterClassCounter, is(equalTo(1)));
    }

    @AfterClass
    public static void assertAnnotatedTestRunsMultipleTimes() {
        assertThat(testCounter, is(equalTo(99)));
    }
}
{% endcodeblock %}

If you annotate the class rather than individual test methods, every test method of the class will be treated as if it were marked as `@Intermittent`.


{% codeblock lang:java %}
@RunWith(IntermittentTestRunner.class)
@Intermittent(repetition = 10)
public class IntermittentTestRunnerTest {

    private static int testCounter = 0;

    @Test
    public void annotatedTest() {
        testCounter++;
    }

    @Test
    public void anotherAnnotatedTest() {
        testCounter++;
    }

    @AfterClass
    public static void assertAnnotatedTestRunsMultipleTimes() {
        assertThat(testCounter, is(equalTo(20)));
    }

}
{% endcodeblock %}



## Parallel Tests

The tempus-fugit library allows you to run tests methods within classes in parallel. Each test method within a class will run on its own thread and in parallel with any other test methods in that class. The number of threads for a given test class will be equal to the number of test methods within that class.

You can use the `ConcurrentTestRunner` runner to run all test methods within a class in parallel. Simply mark your test to be `@RunWith` the `ConcurrentTestRunner` class as below.

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

## Load / Soak Tests

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
    **@Concurrent (count = 5)
    @Repeating (repetition = 10)**
    public void runsMultipleTimes() {
        counter.getAndIncrement();
    }
 }
{% endcodeblock %}

Will repeat the test method ten times in five threads. Each thread will run the test method ten times, so in our example, the counter will be incremented to fifty.

## Wait for Assertions

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



## Interrupt Capturing Thread Stub

It can be tricky to test that an interrupt has been called on a thread because of the possibility of race conditions between calling `interrupt` and checking the status of the interrupt flag using `Thread.isInterrupted()` or `Thread.interrupted`. For example, the interrupt status can be reset when a thread goes into the `TERMINATED` state. You can use the `WaitFor` class to express an assertion must be true within a given time (as below) but in this case, the race conditions can still occur (due to the frequency of the check whilst waiting). In the example below, the created thread will perform some blocking function that can be interrupted (for example, sleeping) and we're testing that the call to `interrupt` will wake and change the interrupt status flag (asserting against `thread.isInterrupted`).



{% codeblock lang:java %}
@Test (timeout = 500)
public void interrupted() throws TimeoutException, InterruptedException {
    final Thread thread = new Thread(new Runnable(...));
    thread.start();
    waitOrTimeout(threadIsWaiting(thread), millis(500));
    thread.interrupt();
    waitOrTimeout(new Condition() {
        public boolean isSatisfied() {
            return thread.isInterrupted();
        }
    }, millis(500));
}{% endcodeblock %}


It may be simpler to use a _stub_ to capture the interrupt. The `InterruptCapturingThread` class of tempus-fugit is just a stub extending `Thread` which records and gives access to stack traces of threads that call `interrupt` on it.



{% codeblock lang:java %}
@Test (timeout = 500)
public void interrupted() throws TimeoutException, InterruptedException {
    InterruptCapturingThread thread = new InterruptCapturingThread(new Runnable(...));
    thread.start();
    waitOrTimeout(threadIsWaiting(thread), millis(500));
    thread.interrupt();
    waitOrTimeout(not(threadIsWaiting(thread)), millis(500));
    **assertThat(thread.getInterrupters().isEmpty(), is(false));**
}{% endcodeblock %}


For testing purposes, you can also get a view on the stack traces of the threads that called `interrupt` on your thread. Calling `thread.printStackTraceOfInterruptingThreads(System.out)` from the example above would show something like the following.


    java.lang.Thread.getStackTrace(Thread.java:1409)
       com.google.code.tempusfugit.concurrency.InterruptCapturingThread.interrupt(InterruptCapturingThread.java:61)
       com.google.code.tempusfugit.concurrency.InterruptCapturingThreadTest.interrupted(InterruptCapturingThreadTest.java:39)
       sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
       sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:39)
       sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:25)
       java.lang.reflect.Method.invoke(Method.java:585)
       org.junit.runners.model.FrameworkMethod$1.runReflectiveCall(FrameworkMethod.java:44)
       org.junit.internal.runners.model.ReflectiveCallable.run(ReflectiveCallable.java:15)
       org.junit.runners.model.FrameworkMethod.invokeExplosively(FrameworkMethod.java:41)
       org.junit.internal.runners.statements.InvokeMethod.evaluate(InvokeMethod.java:20)
       org.junit.internal.runners.statements.FailOnTimeout$1.run(FailOnTimeout.java:28)

[Next, Callables &raquo;](/documentation/callables/)