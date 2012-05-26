---
layout: page
title: "Timeoutable Completion Service"
date: 2012-05-26 16:53
sharing: true
comments: false
footer: false
sidebar: false
categories: [Concurrency Utilities]
---

The `TimeoutableCompletionService` interface describes a service similar to a `java.util.concurrent.CompletionService` except that it will timeout after a specified duration if all results haven't yet been retrieved.

The default implementation, `DefaultTimeoutableCompletionService`, delegates to an underlying `CompletionService` but will stop waiting for submitted tasks to complete after a given timeout.

If the timeout expires before all tasks have been completed, the `DefaultTimeoutableCompletionService` will throw a `TimeoutException`. The exception thrown will also contain the results from any tasks that did manage to complete before the timeout. If all the submitted tasks complete before the timeout expires, the results are returned from the `submit` method and no exceptions are thrown.

In the example below, we'd like to create a status monitoring application that will output the status of a set of probes to a web page. However, the web page must be loaded within a few seconds regardless of whether all the probes have returned their results. The completion service can be used to execute individual status probe tasks in parallel, timing out after some duration.



{% codeblock lang:java %}
private DefaultTimeoutableCompletionService completionService = new DefaultTimeoutableCompletionService(new ExecutorCompletionService(...));

public void probe() {
    try {
        List<Callable<Result>> probes = factory.create();
        List<Result> results = completionService.submit(probes);
        write(results);
    } catch (TimeoutExceptionWithFutures e) {
        write(getResultsFrom(e));
    } catch (ExecutionException e) {
        throw new RuntimeException(e);
    }
}
{% endcodeblock %}

Here, the list of tasks to run in parallel is created by some factory class and assigned to the `probes` variable. These are just a list of `Callable` objects which will be executed by the underlying `Executor`, in our case, they'll look up the status of some probe and return a `Result` object.

The `DefaultTimeoutableCompletionService` is then used to schedule execution of the tasks with the `submit` method. At this point, the code will block and wait for all results to be returned or for the `TimeoutExceptionWithFutures` to be thrown. In the case of all tasks completing within the timeout, the results are just outputted using the `write` method.

For the case where the completion service timed out, a `TimeoutException` is thrown which includes any completed results. The `write` method in this case can just extract the partial set of results from the exception.

The default timeout for the service is thirty seconds but this can be changed using an alternative constructor.



[Next, JUnit Integration &raquo;](/documentation/junit/)