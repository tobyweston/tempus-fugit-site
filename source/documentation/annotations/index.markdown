---
layout: page
title: "Annotations"
date: 2012-05-26 18:26
sharing: true
comments: false
footer: false
sidebar: false
categories: [Annotations]
---


The annotations package contains variations or implementations of Brian Goetz and Tim Peierls' [Concurrency In Practice](http://www.javaconcurrencyinpractice.com/) annotations as well as some additional annotations useful when writing concurrent code.


## @Concurrent

The `Concurrent` annotation is fully documented in the [concurrency](documentation/junit/parallel) section and offers a way to either document a method as potentially being run from a concurrent context or combined with a `ConcurrentRule` or `ConcurrentTestRunner`, mark a JUnit test to run in parallel.


## @Immutable

The `Immutable` annotation offers a way to document the intent that a class should be immutable.

Although potentially difficult to implement fully, this can be combined with AOP to try and enforce immutability. An example of a partially implemented AspectJ aspect is provided with tempus-fugit and reproduced here.


{% codeblock lang:java %}
package com.google.code.tempusfugit.concurrency.annotations;

import java.lang.reflect.Field;
import junit.framework.TestCase;
import com.google.code.tempusfugit.concurrency.annotations.Immutable;

public abstract aspect DeclareImmutableError {

    pointcut testCase() : within(TestCase+);

    pointcut mutators() : call(*.new()) || call(* *.set*(..)) || call(* *.add*(..));

    pointcut immutable() : @within(Immutable);

    declare error : mutators() && immutable() && !testCase() : "Immutable objects should not be mutated";

}
{% endcodeblock %}


Note that the example above doesn't ensure that all members are themselves `Immutable` or that constructors / accessors against collections ensure immutability. It also doesn't support junit tests that do not extend `TestCase`.

## @Intermittent

The `Intermittent` annotation is fully documented in the [concurrency](concurrency.html#Intermittent_Tests) section and offers a way to indicate tests intermittently fail. If you're using JUnit, you can also re-run the tests several times using the `IntermittentTestRunner` classes.

## @Not

The `Not` annotation can be used to explicitly document the intent to _not_ another annotation. For example, to document that some class is not thread- safe and doesn't and should not be immutable (ie, it's intentionally mutable), you could write


{% codeblock lang:java %}
@Not({ThreadSafe.class, Immutable.class})
public class Yagni {
    // ...
}{% endcodeblock %}


You can supply as many arguments as you like as long as they make sense to you.

## @Repeating

The `Repeating` annotation is documented in the [concurrency](/documentation/junit/load) section and offers a mechanism to repeatedly run a test method for load or soak test purposes. It can be combined with the `Concurrent` annotation to run test methods multiple times across multiple threads.

## @Task

The `Task` annotation is intended to document that a class is a concurrent task. A vanilla `Runnable` or `Callable` implementation for example may be used to implement some general purpose piece of functionality. Often, these will represent small tasks to be executed in serial, by annotating it as a _task_, you convey that the intended usage is from a concurrent context. For example, the `Runnable` will be run in parallel with other tasks.

{% blockquote Goetz et al, Concurrency in Practice %}
Most concurrent applications are organised around the execution of tasks: abstract, discrete units of work. Dividing the work of an application into tasks simplifies organisation, facilitates error recovering by providing natural transaction boundaries, and promotes concurrency by providing a natural structure for paralleslising work.
{% endblockquote %}

With this annotation, when we talk about _tasks_ we really mean _concurrent tasks_.

## @ThreadSafe

The `ThreadSafe` annotation is a direct implementation of the Goetz version. It is used to document that the author _thinks_ a class is thread safe.


## @GuardedBy

The `GaurdedBy` annotation is a variation on the Goetz version whereby the the lock and lock details are explicitly set as parameter types. See [ Concurrency In Practice](http://www.javaconcurrencyinpractice.com/) for an in-depth description of it's use.

The enum `GuardedBy.Type` defines the following lock types based on the Goetz version.

  * `THIS`
  * `INNER_CLASS_THIS`
  * `ITSELF`
  * `FIELD`
  * `STATIC_FIELD`
  * `METHOD`

### THIS

In the example below, shows how the `THIS` lock type is used. All access to the `bar` member is guarded by the instance monitor object off `Foo`.



{% codeblock lang:java %}
public class Foo {
    @GuardedBy(lock = THIS) private final Bar bar = ...

    public synchronized void raise() {
        bar.raise();
    }

    public void lower() {
        synchronized(this) {
            bar.lower();
        }
    }
}
{% endcodeblock %}

### INNER_CLASS_THIS

The `INNER_CLASS_THIS` type is a way of disambiguating from `THIS` when it's used from an inner class. However, it's marked as deprecated as `THIS` can still be used and disambiguated by using the `details` parameter. For example,



{% codeblock lang:java %}
public class Foo {
    @GuardedBy(lock = THIS, details = "Callable.class") private final Bar bar = ...

    public void raise() {
        new Callable() {
            public synchronized void call() {
                bar.raise();
            }
        };
    }
}
{% endcodeblock %}

### ITSELF

It may be necessary to indicate that another object is responsible for its own synchronisation policy. For example, when avoiding `ConcurrentModificationException` on summing a list of numbers below, we declare our `List` using `Collections.synchronizedList`. Internally, this thread-safe list uses itself to guard access, we reflect this using the annotation as below.



{% codeblock lang:java %}
public class Foo {
    @GuardedBy(lock = ITSELF) private final List<Integer> numbers = Collections.synchronizedList(new ArrayList<Integer>);

    public void addNumber(int number) {
        numbers.add(number);
    }

    public int sum() {
        int sum = 0;
        synchronized(numbers) {
            for (int number : numbers) {
                sum += number;
            }
        }
        return sum;
    }
}
{% endcodeblock %}

### FIELD and STATIC_FIELD

Using a field to synchronise access can be seen in the example below (based on an example from Goetz).



{% codeblock lang:java %}
public class PrivateLock {
    private final Object myLock = new Object();
    @GuardedBy(lock = FIELD, details = "myLock") Widget widget;

    void someMethod() {
        synchronized (myLock) {
            // Access or modify the state of widget
        }
    }
}
{% endcodeblock %}


### METHOD

When a lock is obtained via some method, the `METHOD` type along with a `details` can be used. A trivial example is shown below. We haven't found much use for this type, but that's not to say that you won't



{% codeblock lang:java %}
public class Foo {
    @GuardedBy(lock = METHOD, details = "getLock()") private final Bar bar = ...

    public void raise() {
        synchronized(getLock()) {
            bar.raise();
        }
    }

    private Object getLock() {
        // ...
    }
}
{% endcodeblock %}


