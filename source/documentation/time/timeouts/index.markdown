---
layout: page
title: "Timeouts"
date: 2012-05-26 17:45
comments: false
sharing: true
footer: false
sidebar: false
categories: [Time Sensitive Code]
---

The `Timeout` class takes a `Duration` representing a period after which a timeout has occurred. The timeout status of the object is checked using the `hasExpired` method. **Note** that the timeout uses a `StopWatch` internally and that the stop watch is started on construction.

`Timeout` class is combined with a `Condition` to implement the `waitUntil` method of `WaitFor` which waits until a timeout expires rather than for a condition to be met.


[Next, Testing Time Sensitive Code: Testing with the Clock Interface &raquo;](/documentation/time/clocks)