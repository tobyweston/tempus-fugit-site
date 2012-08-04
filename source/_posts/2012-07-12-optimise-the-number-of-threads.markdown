---
layout: post
title: "Optimise the Number of Threads"
date: 2012-07-12 19:01
comments: true
categories: [Concurrency, Performance]
sidebar: false
keywords: "optimal number of threads, cpu bound, io bound, goetz, java, tempus-fugit"
description: "Understand the theoretical optimal number of threads you need in your app. We look at CPU bound and IO bound application profiles."
---

Working out the theoretical optimal number of threads you should use for your application is fairly straightforward. You do, however, need to understand your applications runtime characteristics. Is it mostly occupied with CPU intensive work or is it mostly waiting for IO? A [good profiler](http://www.yourkit.com/) will help you to understand your applications profile.

<!-- more -->

## CPU Bound Tasks

For CPU bound tasks, Goetz (2002, 2006.) recommends

    threads = number of CPUs + 1

Which is intuitive as if a CPU is being kept busy, we can't do more work than the number of CPUs. Goetz purports that the additional CPU has been shown as an improvement over omitting it (2006.), but others don't agree and suggest the number of CPUs is optimal.

## IO Bound Tasks

Working out the optimal number for IO bound tasks is less obvious. During an IO bound task, a CPU will be left idle (waiting or blocking). This idle time can be better used in initiating another IO bound request.

Subramaniam (2011, p.31) describes the optimal number of threads in terms of the following formula.

    threads = number of cores /  (1 – blocking coefficient)

{% img ../../../../../images/subramaniam.gif %}

And Goetz (2002) describes the optimal number of threads in terms of the following.

    threads = number of cores * (1 + wait time / service time)

{% img ../../../../../images/goetz.gif %}

Where we can think of `wait time / service` time as a measure of how contended the task is.

## Goetz and Subramaniam Agree

Just out of interest, we can show that both IO bound formulas are equivalent. Starting with Goetz’s formula, we assert that `w+s=1` and remove the service time (`s`) giving the following

{% img ../../../../../images/goetz-2.gif %}

We can continue by multiplying both sides by `1-w` reducing the right hand side to `c` before reversing the operation and revealing Subramaniam’s expression.

{% img ../../../../../images/goetz-3.gif %}

{% img ../../../../../images/goetz-4.gif %}

{% img ../../../../../images/subramaniam.gif %}

Thanks to [Jazzatola](https://twitter.com/Jazzatola) for mathematical input.


## References

- Goetz, B. 2002. [Java theory and practice: Thread pools and work queues](http://www.ibm.com/developerworks/java/library/j-jtp0730/index.html). IBM DeveloperWorks.
- Goetz, B. Peierls, T. Bloch, J. Bowbeer, J. Holmes, D. and Lea, D. 2006. [Java Concurrency in Practice](http://amzn.to/NrXQPZ). 1st Edition. Addison Wesley.
- Subramaniam, V. 2011. [Programming Concurrency on the JVM](http://amzn.to/NrXXuI). 1st Edition. Pragmatic Bookshelf.