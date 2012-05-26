---
layout: page
title: "Intermittent Tests"
date: 2012-05-26 17:12
sharing: true
comments: false
footer: false
sidebar: false
categories: [JUnit Integration]
---

As much as possible, you aim to have a completely deterministic tests but despite your best efforts, the odd flickering test can still get through. Occasionally, you might want to run such a test repeatedly to get an idea of its indeterminacy. The `Intermittent` annotation can be combined with the `IntermittentTestRunner` to provide this behaviour along side [junit](http://junit.org/).

You simply mark a junit test method (or class) as potentially intermittent using the `Intermittent` annotation as follows.


{% codeblock lang:java %}
@Test
@Intermittent
public void flickering() {
   // ...
}
{% endcodeblock %}


You can then use the `@RunWith` annotation to run the test using the `IntermittentTestRunner`. Any `@Before` or `@After` methods will be run once for each test repetition. The example below also shows that the repetition count can be overridden on the method annotation.


{% codeblock lang:java %}
@RunWith(IntermittentTestRunner.class)
public class IntermittentTestRunnerTest {

    private static int testCounter = 0;
    private static int afterCounter = 0;
    private static int afterClassCounter = 0;

    @Test
    @Intermittent(repetition = 99)
    public void annotatedTest() {
        testCounter++;
    }

    @After
    public void assertAfterIsCalledRepeatedlyForAnnotatedTests() {
        assertThat(testCounter, is(equalTo(++afterCounter)));
    }

    @AfterClass
    public static void assertAfterClassIsCalledOnce() {
        assertThat(++afterClassCounter, is(equalTo(1)));
    }

    @AfterClass
    public static void assertAnnotatedTestRunsMultipleTimes() {
        assertThat(testCounter, is(equalTo(99)));
    }
}
{% endcodeblock %}

If you annotate the class rather than individual test methods, every test method of the class will be treated as if it were marked as `@Intermittent`.


{% codeblock lang:java %}
@RunWith(IntermittentTestRunner.class)
@Intermittent(repetition = 10)
public class IntermittentTestRunnerTest {

    private static int testCounter = 0;

    @Test
    public void annotatedTest() {
        testCounter++;
    }

    @Test
    public void anotherAnnotatedTest() {
        testCounter++;
    }

    @AfterClass
    public static void assertAnnotatedTestRunsMultipleTimes() {
        assertThat(testCounter, is(equalTo(20)));
    }

}
{% endcodeblock %}



[Next, JUnit Integration: Running Tests in Parallel &raquo;](/documentation/junit/parallel/)