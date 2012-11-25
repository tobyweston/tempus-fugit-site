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
  <version>1.1</version>
</dependency>
{% endcodeblock %}

You can also download the jar directly from [repo2.maven.org](http://repo2.maven.org/maven2/com/google/code/tempus-fugit/tempus-fugit/) or [Sonatype](http://oss.sonatype.org/content/groups/public/com/google/code/tempus-fugit/tempus-fugit/) or using something like `curl` from the terminal.

{% codeblock lang:bash %}
$ curl http://repo2.maven.org/maven2/com/google/code/tempus-fugit/tempus-fugit/1.1/tempus-fugit-1.1.jar > tempus-fugit-1.1.jar
$ mvn install:install-file -Dfile=tempus-fugit-1.1.jar -DgroupId=com.google.code.tempus-fugit -DartifactId=tempus-fugit -Dversion=1.1 -Dpackaging=jar
{% endcodeblock %}

## Snapshots

Snapshots are deployed to [OSS Sonatype](https://oss.sonatype.org/content/repositories/snapshots/com/google/code/tempus-fugit/tempus-fugit). They're not picked up by Maven central so if you want to use a snapshot release in your projects, you'll need to add the Sonatype snapshot repository to your list of repositories.

You can do this in your `settings.xml` or `pom.xml` by adding something like this.

{% codeblock lang:xml %}
<repositories>
    <repository>
        <id>sonatype-nexus-snapshots</id>
        <name>Sonatype Nexus Snapshots</name>
        <url>https://oss.sonatype.org/content/repositories/snapshots</url>
        <releases>
            <enabled>false</enabled>
        </releases>
        <snapshots>
            <enabled>true</enabled>
        </snapshots>
    </repository>
</repositories>
{% endcodeblock %}