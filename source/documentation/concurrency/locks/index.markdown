---
layout: page
title: "Always Execute Using Locks"
date: 2012-05-26 16:54
sharing: true
comments: false
footer: false
sidebar: false
categories: [Concurrency Utilities]
---

Using implementations of the `java.util.concurrent.locks.Lock` requires that the lock is acquired and released after use. This leads to the common idiom below.


{% codeblock lang:java %}
Lock lock = new ReentrantLock();
lock.lock;
try {
   // something useful
} finally {
    lock.unlock();
}
{% endcodeblock %}


The `ExecuteUsingLock` class provides a way to abstract the lock acquisition and release and ensure consistency across your code. It takes a `Callable` representing the statements to execute whilst the lock is acquired and the actual lock to use when executing and ensures the lock is always released.



{% codeblock lang:java %}
public void forExample {
    execute(something()).using(lock);
}

private Callable<Void, RuntimeException> something() {
    return new Callable<Void, RuntimeException>() {
        public Void call() throws RuntimeException {
            return null;
        }
    };
}
{% endcodeblock %}




[Next, Concurrency Utilities: Timeoutable Completion Service &raquo;](/documentation/concurrency/completion)