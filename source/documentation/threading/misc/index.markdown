---
layout: page
title: "Miscellaneous"
date: 2012-05-25 19:44
sharing: true
comments: false
footer: false
sidebar: false
categories: documentation
---

## Wrap Exceptions as Another Type

  * Not exclusively for concurrent use, the `ExceptionWrapper` class allows you to run arbitrary code in a `Callable` block catching any `Throwable` as an exception of your choice, embedded the originating exception as the new exception's `cause`. For example,


{% codeblock lang:java %}
ExceptionWrapper.wrapAnyException(new Callable<Object>() {
    @Override
    public Object call() throws ServiceException {
        // nasty code throwing a bunch of exceptions
    }
}, WithException.with(CalendarException.class));
{% endcodeblock %}


You can also catch any `Exception` and rethrow as a `RuntimeException` with the originating exception as the `cause`. The example below shows the anonymous `Callable` being created in the method `something`.


{% codeblock lang:java %}
ExceptionWrapper.wrapAsRuntimeException(something());
{% endcodeblock %}


## A Default Thread Factory

  * As a convenience class, the `DefaultThreadFactory` offers an implementation of `java.util.concurrent.ThreadFactory` that creates a thread using the single argument constructor of `Thread`.



[**Next** &raquo; *Concurrency Utilities* &raquo;](/documentation/threading/concurrency/)
