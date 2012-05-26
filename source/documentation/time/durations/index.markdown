---
layout: page
title: "Durations"
date: 2012-05-26 17:43
comments: false
sharing: true
footer: false
sidebar: false
categories: [Time Sensitive Code]
---

Frequently, some length of time is represented as a `long` in Java. The trouble here is that you don't always know what time unit the `long` represents and as [Effective Java](http://java.sun.com/docs/books/effective/) recommends, you'll often end up with something like the following


{% codeblock lang:java %}
connection.setReadTimeout(TIMEOUT_IN_MILLIS);
{% endcodeblock %}

or you might come across unhelpful code like this;

{% codeblock lang:java %}
connection.setReadTimeout(1000 * 2 * 60);
{% endcodeblock %}

This is all very error prone, ugly and in the second case, fails to convey the intent. The `Duration` class captures a length of time and forces you to express the time unit. So, for example,

{% codeblock lang:java %}
connection.setReadTimeout(seconds(2);
{% endcodeblock %}


Using `Duration` in your own method forces your clients to create use an explicit time unit and you can convert back explicitly. for example,


{% codeblock lang:java %}
public void setReadTimeout(Duration timeout) {
   ...
   readTimeout = timeout.inMillis();
   ...
}
{% endcodeblock %}



[Next, Testing Time Sensitive Code: Conditions &raquo;](/documentation/time/conditions)