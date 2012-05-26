---
layout: page
title: "Miscellaneous"
date: 2012-05-25 19:44
sharing: true
comments: false
footer: false
sidebar: false
categories: [Thread Utilities]
---

## Wrap Exceptions

The `ExceptionWrapper` class allows you to run arbitrary code in a `Callable` block catching any `Throwable` and rethrowing as an exception of your choice. The thrown exception embeds the originating exception as it's cause. For example,


{% codeblock lang:java %}
ExceptionWrapper.wrapAnyException(new Callable<Object>() {
    @Override
    public Object call() throws ServiceException {
        // nasty code throwing a bunch of exceptions
    }
}, WithException.with(CalendarException.class));
{% endcodeblock %}


If you'd rather just convert checked exceptions to `RuntimeException`, just use the 'wrapAsRuntimeException` method. Again, it will embed the originating exception so you won't loose the information.

The example below has the creation of the anonymous `Callable` class pushed into the method `something`.


{% codeblock lang:java %}
ExceptionWrapper.wrapAsRuntimeException(something());
{% endcodeblock %}


## Default Thread Factory

Nothing fancy, the `DefaultThreadFactory` offers the default implementation of `java.util.concurrent.ThreadFactory` shown below.

{% codeblock lang:java %}
public class DefaultThreadFactory implements ThreadFactory {

    public Thread newThread(Runnable runnable) {
        return new Thread(runnable);
    }
}{% endcodeblock %}


[Next, Concurrency Utilities &raquo;](/documentation/concurrency/)
