---
layout: page
title: "Downloading"
date: 2012-05-20 20:33
comments: false
sharing: true
footer: false
categories: documentation
sidebar: false
---

Download via the public [Maven Central repository](http://repo1.maven.org/maven2/). Just add the dependency to your pom.

{% codeblock lang:xml %}
<dependency>
  <groupId>com.google.code.tempus-fugit</groupId>
  <artifactId>tempus-fugit</artifactId>
  <version>1.1-SNAPSHOT</version>
</dependency>
{% endcodeblock %}

You can also download the jar directly from [repo2.maven.org](http://repo2.maven.org/maven2/com/google/code/tempus-fugit/tempus-fugit/) or [Sonatype](http://oss.sonatype.org/content/groups/public/com/google/code/tempus-fugit/tempus-fugit/) or using something like `curl` from the terminal.

{% codeblock lang:bash %}
$ curl http://repo2.maven.org/maven2/com/google/code/tempus-fugit/tempus-fugit/1.1/tempus-fugit-1.1.jar > tempus-fugit-1.1.jar
$ mvn install:install-file -Dfile=tempus-fugit-1.1.jar -DgroupId=com.google.code.tempus-fugit -DartifactId=tempus-fugit -Dversion=1.1 -Dpackaging=jar
{% endcodeblock %}
