---
layout: post
title: "Testing Concurrent Code"
date: 2012-05-20 20:33
comments: true
sidebar : false
categories: [Testing, Concurrency]
---

## Separate the Concurrency Policy from Behaviour

Testing stuff concurrently is hard. [GOOS](http://www.growing-object-oriented-software.com/) amongst other people recommend separating the concurrency policy from the parts of the system that are doing the work. So, for example, if you have some form of "executor" which is responsible for farming work out concurrently and behaviour defined separately, you can test each independently and just verify that they collaborate to achieve "worker" behaviour concurrently. Make sense?

<!-- more -->

As an example, [this test from tempus-fugit](https://github.com/tobyweston/tempus-fugit/blob/master/tempus-fugit/src/test/java/com/google/code/tempusfugit/concurrency/ConcurrentSchedulerTest.java) demonstrates the idea. The `Scheduler`'s behaviour (which is essentially to "schedule" tasks) is independent from _how_ it actually achieves this. In this case, it delegates to an `Executor` and so this doesn't need to be tested with any threads. It's a simple collaborator style test.

Having said that, there may be times you actually want to run your class 'in context' in a multi-threaded way. The trick here is to keep the test deterministic. Well, I say that, there's a couple of choices...

## Deterministic

If you can setup your test to progress in a deterministic way, waiting at key points for conditions to be met before moving forward, you can try to simulate a specific process interleaving to test. This means understanding exactly what you want to test (for example, forcing the code into a deadlock) and stepping through deterministically (for example, using abstractions like `CountdownLatche` to *synchronise* the moving parts).

When you attempt to make some multi-threaded test syncrhonise its moving parts, you can use whatever concurrency abstraction is available to you but it's difficult because its concurrent; things could happen in an unexpected order. Often people try to mitigate this in tests by introducing `sleep` calls. We generally don't like to sleep in a test because it can introduce non-determinism. Just because the right sleep amount on one machine *usually* causes the affect you're looking for, it doesn't mean it'll be the same on the next machine. It'll also make the test run slower and when you've got thousands of tests to run, every ms counts. If you try and lower the sleep period, more non-determinism comes in. It's not pretty.

Some examples of forcing specific interleaving include

 - [Forcing a deadlock](https://github.com/tobyweston/tempus-fugit/blob/master/tempus-fugit/src/test/java/com/google/code/tempusfugit/concurrency/DeadlockDetectorTest.java) using `CountdownLatch`
 - [Setting up a thread to be interrupted](https://github.com/tobyweston/tempus-fugit/blob/master/tempus-fugit/src/test/java/com/google/code/tempusfugit/concurrency/ThreadUtilsTest.java)


Another gotcha is where the main test thread will finish before any newly spawned threads under test complete. This is an easy trap to fall into with UI testing. Waiting for a specific condition rather than allowing the test thread to finish often helps. For example using [WaitFor](/documentation/time/waiting). See the article [Be Explicit with the UI Thread](http://baddotrobot.com/blog/2008/12/30/be-explicit-about-ui-thread-in-swt/) for more details around this for UI testing.


## Soak / Load Testing

Another choice is to bombard your classes in an attempt to overload them and force them to betray some subtle concurrency issue. Here, just as in the other style, you'll need to setup up specific assertions so that you can tell if and when the classes betray themselves. Of course there is no guarantee that you'll simulate a problem, you might never see the unlike timing needed.

tempus-fugit offer a declarative way to setup tests to run repeatedly and in parallel, see [Load / Soak Tests](/documentation/junit/load).

