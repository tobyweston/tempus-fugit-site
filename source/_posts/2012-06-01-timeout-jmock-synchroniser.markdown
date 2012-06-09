---
layout: post
title: "Timeout in JMock Synchroniser"
date: 2012-06-01 21:15
categories: [Concurrency, Mocking]
comments: true
sidebar : false
---

JMock's `Synchronizer` serialises access to the mock object's "context", it means all invocations of mocked methods call will be `synchronized` on the same monitor, effectively forcing them to run in sequence without thread safety concerns. As it uses `synchronized` though, you can (with some effort) get into trouble with tests that never finish.

If you're seeing this kind of thing, appart from using the `@Test(timeout=1000)` annotation, you might consider an alternative `ThreadingPolicy` implementation using `Lock`s that can timeout and maintain liveliness.

<!-- more -->

{% codeblock lang:java %}

public class TimingOutSynchroniser implements ThreadingPolicy {

    private final Lock lock = new ReentrantLock();
    private final Condition awaitingStatePredicate = lock.newCondition();
    private final Duration lockTimeout;

    private Error firstError = null;

    public TimingOutSynchroniser() {
        this(millis(250));
    }

    public TimingOutSynchroniser(Duration timeout) {
        this.lockTimeout = timeout;
    }

    public void waitUntil(StatePredicate predicate) throws InterruptedException {
        waitUntil(predicate, new InfiniteTimeout());
    }

    /**
     * Waits up to a timeout for a StatePredicate to become active.  Fails the
     * test if the timeout expires.
     */
    public void waitUntil(StatePredicate predicate, long timeoutMs) throws InterruptedException {
        waitUntil(predicate, new FixedTimeout(timeoutMs));
    }

    private void waitUntil(StatePredicate predicate, Timeout testTimeout) throws InterruptedException {
        try {
            lock.tryLock(lockTimeout.inMillis(), MILLISECONDS);
            while (!predicate.isActive()) {
                try {
                    awaitingStatePredicate.await(testTimeout.timeRemaining(), MILLISECONDS);
                } catch (TimeoutException e) {
                    if (firstError != null)
                        throw firstError;
                    Assert.fail("timed out waiting for " + asString(predicate));
                }
            }
        } finally {
            if (lock.tryLock())
                lock.unlock();
        }

    }

    public Invokable synchroniseAccessTo(final Invokable mockObject) {
        return new Invokable() {
            public Object invoke(Invocation invocation) throws Throwable {
                return synchroniseInvocation(mockObject, invocation);
            }
        };
    }

    private Object synchroniseInvocation(Invokable mockObject, Invocation invocation) throws Throwable {
        try {
            lock.tryLock(lockTimeout.inMillis(), MILLISECONDS);
            try {
                return mockObject.invoke(invocation);
            } catch (Error e) {
                if (firstError == null)
                    firstError = e;
                throw e;
            } finally {
                awaitingStatePredicate.signalAll();
            }
        } finally {
            if (lock.tryLock())
                lock.unlock();
        }
    }
}
{% endcodeblock %}
