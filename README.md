# ENA Spring Boot Microservices Cookbook

This project sets out guidelines and recipies to enable Spring Boot based projects developed within ENA to be consistent and easy to deploy and manage.

# Gradle

## Basics
### Name
The name of a Gradle project defaults to the directory name. The project name is also used as the default name for the jar archieve that is built.
For this reason it is important to specifically declare the project name in settings.gradle so that anyone checking out the project into a different directory produces the correctly name artifact.

The project name should be in the format:

`
ena-<name>
`

In [settings.gradle](example/settings.gradle) the project name is specified by:

```groovy
rootProject.name ='ena-example'
```

### Group Name
The group name should be in the format:

`
uk.ac.ebi.ena.<project-name>
`

For example a project with the name ena-example has the group name set in [build.gradle](example/build.gradle) as follows:

```groovy
group = 'uk.ac.ebi.ena.ena-example'
```

### Version
All projects should maintain a version number in [build.gradle](example/build.gradle) in line with the recommendations of [Semantic Versioning 2.0](http://semver.org/).

For example:

```groovy
version = '1.0.0'
```

### Source Compatibility
All projects need to compiled to support Java 8 and be able to run on a JDK 1.8 VM. Therefore we need to add the sourceCompatibility option to [build.gradle](example/build.gradle):

```groovy
sourceCompatibility = 1.8
```

### Repositories
We have our own internal [Artifactory Server](http://ena-dev:8081/artifactory) that provides both our own internal artifacts and keeps a cache of those from public Maven repositories.

Instead of referring to external repositories such as Maven Central directly always specify the our Artifactory server as the repository as it means that all artifacts are cached.
Also add mavenLocal() as the first repository to check as then once you have the artifacts downloaded on your local machine Gradle will use those first before going to Artifactory.

The repository block in [build.gradle](example/build.gradle) will look like this:

```groovy
repositories {
	mavenLocal()
	maven{ url "http://ena-dev:8081/artifactory/all" }
}
```

## Plugins
Plugins in Gradle can be specified in two ways: using the apply plugin attibute and the newer plugins block.

The following plugins should be included in Spring Boot projects:

### Java Plugin
The [Java plugin](https://docs.gradle.org/current/userguide/java_plugin.html) adds Java compilation along with testing and bundling capabilities to a project.

It is added to [build.gradle](example/build.gradle) with:

```groovy
apply plugin: 'java'
```

### Jacoco Plugin
The [JaCoCo plugin](https://docs.gradle.org/current/userguide/jacoco_plugin.html) provides code coverage metrics for Java code and is used by Sonar.

It is added to [build.gradle](example/build.gradle) with:

```groovy
apply plugin: 'jacoco'
```

### Maven-publish Plugin
The [Maven Publish plugin](https://docs.gradle.org/current/userguide/publishing_maven.html) provides the ability to publish in the Maven format. We use this for publishing artifacts to Artifactory.

It is added to [build.gradle](example/build.gradle) with:

```groovy
apply plugin: 'maven-publish'
```

### Spring Boot Plugin
The [Spring Boot Gradle plugin](https://docs.spring.io/spring-boot/docs/current/reference/html/build-tool-plugins-gradle-plugin.html) provides Spring Boot support to Gradle. As well as allowing us to package applications as executable jars it also deals with dependency management of Spring related dependencies.
This means that when we specify the Spring Boot version all other Spring dependency versions are worked out for you so that they are compatable with each other.

It is added to the plugin block of [build.gradle](example/build.gradle) with:

```groovy
plugins {
    id 'org.springframework.boot' version '1.5.6.RELEASE'
}
```

### SonarQube Plugin
The [SonarQube plugin](https://plugins.gradle.org/plugin/org.sonarqube) enables SonarQube analysis to our [Sonar](http://ena-dev:9000/) server.

This uses static analysis to highlight bugs and improvements from rules defined on the server. It also runs test coverage and collects statistics such as lines of code.

It is added to the plugin block of [build.gradle](example/build.gradle) with:

```groovy
plugins {
	id 'org.sonarqube" version '2.5'
}
```
To use SonarQube further configuration is required in a local [gradle.properties](example/gradle.properties) file.

## gradle.properties
[gradle.properties](example/gradle.properties)

### SSH Plugin
The [SSH Plugin](https://gradle-ssh-plugin.github.io/) allows us to remotely call execute commands on remote servers using SSH. We do this as part of the deployment process.

It is added to the plugin block of [build.gradle](example/build.gradle) with:

```groovy
plugins {
	id 'org.hidetake.ssh' version '2.7.0'
}
```

## Gradle Wrapper
Gradle Wrapper gets rid of the need to have Gradle installed on a machine before being able to build a project. It lets us specify a specific version of Gradle and then generates a wrapper script that when run automatically downloads the correct version of Gradle for the project. This avoids also avoids incompatability with different Gradle version.

If is added as a block in [build.gradle](example/build.gradle) with:

```groovy
task wrapper(type: Wrapper) {
    gradleVersion = '4.0.2'
}
```