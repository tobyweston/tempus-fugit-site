---
layout: post
title: "Make JMock Thread Safe"
date: 2012-06-01 19:00
categories: [Concurrency, Mocking]
comments: true
sidebar : false
---

By default, JMock's "context" is not thread safe. All bets are off if you access the `Mockery` from  multiple threads. Happily, since JMock 2.6.0, you can set a threading policy per mockery.

{% codeblock lang:java %}
{% assign braces = '{{' %}
Mockery mockery = new JUnit4Mockery() {{ braces }}
	setThreadingPolicy(new Synchroniser());
}};{% endcodeblock %}



The `Synchroniser` forces serialisation of each mocked method call using `synchronized`. Use it when you're running multi-threaded style tests using JMock. The default behaviour will warn you if a mockery is being used like this.

	the Mockery is not thread-safe: use a Synchroniser to ensure thread safety
	
	


