---
layout: post
title: "Avoid JMock Finaliser Problems"
date: 2012-06-01 23:22
categories: [Concurrency, Mocking]
comments: true
sidebar : false
---

The default threading policy for a JMock `Mockery` warns if the mockery is being used by multiple threads. The `SingleThreadedPolicy` will output the following.

	2012-05-31 07:35:35 ERROR Finalizer [Console$Logger] - the Mockery is not thread-safe: use a Synchroniser to ensure thread safety


If you really need multi-threaded access to the mockery, it's a [straight forward fix](/recipes/2012/06/01/making-jmock-thread-safe) to swap the policy out. As in the log line above though, sometimes the JVM's finaliser thread sticks it's oar in and confuses the `SingleThreadedPolicy`.

To get rid of this, you can set a custom threading policy that performs the same check as the default, just not when the finaliser thread is involved.

{% codeblock lang:java %}
{% assign braces = '{{' %}
private final Mockery context = new Mockery() {{ braces }}
    setThreadingPolicy(new SingleThreadedPolicyAvoidingFinaliseProblems());
}};
{% endcodeblock %}

{% codeblock lang:java %}
public static class SingleThreadedPolicyAvoidingFinaliseProblems extends SingleThreadedPolicy {
    @Override
    public Invokable synchroniseAccessTo(Invokable unsynchronizedInvocation) {
        Invokable synchronizedInvocation = super.synchroniseAccessTo(unsynchronizedInvocation);
        return new InvokeBasedOnCurrentThreadBeingTheFinalizerThread(unsynchronizedInvocation, synchronizedInvocation);
    }
}

private static class InvokeBasedOnCurrentThreadBeingTheFinalizerThread implements Invokable {

    private final Invokable whenOnFinalizerThread;
    private final Invokable whenNotFinalizerThread;

    public InvokeBasedOnCurrentThreadBeingTheFinalizerThread(Invokable whenOnFinalizerThread, Invokable whenNotFinalizerThread) {
        this.whenOnFinalizerThread = whenOnFinalizerThread;
        this.whenNotFinalizerThread = whenNotFinalizerThread;
    }

    @Override
    public Object invoke(Invocation invocation) throws Throwable {
        if (currentThreadIs("Finalizer"))
            return whenOnFinalizerThread.invoke(invocation);
        return whenNotFinalizerThread.invoke(invocation);
    }

    private static boolean currentThreadIs(String name) {
        return Thread.currentThread().getName().equalsIgnoreCase(name);
    }
}
{% endcodeblock %}

See the bug report [JMOCK-256](http://jira.codehaus.org/browse/JMOCK-256) for more details.