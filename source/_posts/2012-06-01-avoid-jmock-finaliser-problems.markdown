---
layout: post
title: "Avoid JMock Finaliser Problems"
date: 2012-06-01 23:22
categories: [Concurrency]
comments: true
sidebar : false
---

The default threading policy for a JMock `Mockery` warns if the mockery is being used by multiple threads. The `SingleThreadedPolicy` will output the following.

	the Mockery is not thread-safe: use a Synchroniser to ensure thread safety


If you really need multi-threaded access to the mockery, it's a [straight forward fix](/2012-06-01-making-jmock-thread-safe.html) to swap the policy out. However, sometimes the JVM's finaliser thread sticks it's oar in and confuses the `SingleThreadedPolicy`.

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
    public Invokable synchroniseAccessTo(final Invokable mockObject) {
        final Invokable synchronizedMockObject = super.synchroniseAccessTo(mockObject);
        return new Invokable() {
            @Override
            public Object invoke(Invocation invocation) throws Throwable {
                if (Thread.currentThread().getName().equalsIgnoreCase("Finalizer"))
                    return mockObject.invoke(invocation);
                return synchronizedMockObject.invoke(invocation);
            }
        };
    }
}
{% endcodeblock %}

See bug report [JMOCK-256](http://jira.codehaus.org/browse/JMOCK-256) for more details.