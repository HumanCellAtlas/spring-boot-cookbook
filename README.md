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

It is added as a block in [build.gradle](example/build.gradle) with:

```groovy
task wrapper(type: Wrapper) {
    gradleVersion = '4.0.2'
}
```

## Dependencies
[Spring Boot Starters](https://github.com/spring-projects/spring-boot/tree/master/spring-boot-starters) are bundles of dependencies that make it more straight forward to get the correct dependencies for a Spring Boot project. We typically use the following bundles.

### Spring Boot Starter Web
The Spring Boot Starter Web dependencies provides the core of Spring, web libraries including support for JSON serialisation, logging and an embedded Tomcat server. This is an opionated default of what is needed for a Spring Boot Web application.

It is added to the dependencies block in [build.gradle](example/build.gradle) with:

```groovy
dependencies {
    compile('org.springframework.boot:spring-boot-starter-web')
}
``` 

Note how no version number is provided. This is handled automatically by the Spring Boot Plugin's dependency management.

### Spring Boot Starter Test
The Spring Boot Starter Test dependencies provide a set of testing libraries including JUnit and the Mockito mocking framework.

It is added to the dependencies block in [build.gradle](example/build.gradle) with:

```groovy
dependencies {
    testCompile('org.springframework.boot:spring-boot-starter-test')
}
``` 

## Publication

### Manifest
We use Gradle to create a META-INF/MANIFEST file in the generated jar. this contains as a minimum the project name, version and source capatibility. This is used in the deployment process to verify that the correct artifact is being used.

It is added as a block in [build.gradle](example/build.gradle) with:

```groovy
jar.manifest {
    attributes('Implementation-Title': project.name,
            'Implementation-Version': project.version,
            'Source-Compatibility': project.sourceCompatibility
    )
}
```

### sourceJar
As well as the binary we also publish a source code jar to the Artifactory. This means that when someone else depends on our library they can download and examine the source code.

The task to do this is added in [build.gradle](example/build.gradle) with:

```groovy
task sourceJar(type: Jar) {
    from sourceSets.main.allJava
}
```

### Artifactory Publishing
The block in [build.gradle](example/build.gradle) to enable Artifactory publishing is as follows:

```groovy
publishing {
    publications {
        mavenJava(MavenPublication) {
            from components.java
            artifact sourceJar {
                classifier "sources"
            }
        }
    }
    repositories {
        maven {
            credentials {
                username artifactoryUsername
                password artifactoryPassword
            }
            url "http://ena-dev:8081/artifactory/libs-release-local"
        }
    }
}
```

This specifies to publish both the artifact and the generated source jar to our Artifactory server in the Maven format.

The artifactoryUsername and artifactoryPassword need to be configuration is required in a local [gradle.properties](example/gradle.properties) file for publication to be successful. This keeps sensitive passwords out of the source code.

## gradle.properties
[gradle.properties](example/gradle.properties)

# Java Application

## Application.java
For consistency the main class of a Spring Boot application should be called [Application.java](example/src/main/java/uk/ac/ebi/ena/example/Application.java). 

This is inline with the [Getting Started examples on spring.io](https://spring.io/guides/gs/spring-boot/).

Monit is the tool we use for monitoring of our deployed application processes. To do this monit needs to know the PID of the running process. We get Spring Boot to generate this using the [ApplicationPidFileWriter](http://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/system/ApplicationPidFileWriter.html).

For the deployment scripts to work this needs to be named \<project-name\>.pid. So for a project named ena-example the main method in the [Application.java](example/src/main/java/uk/ac/ebi/ena/example/Application.java) will look like this:

```java
@SpringBootApplication
public class Application {

	private static String PID_FILE = "ena-example.pid";

	public static void main(String[] args) throws Exception {
		SpringApplication springApplication = new SpringApplication(Application.class);
		springApplication.addListeners(new ApplicationPidFileWriter(PID_FILE));
		springApplication.run(args);
	}

}
```
## Spring Boot Actuator
[Spring Boot Actuator](https://spring.io/guides/gs/actuator-service/) includes a number of additional features to help us monitor and manage our applications. These include the health of the application and memory usage as examples.

To add it we need to add the dependency into the dependencies block in [build.gradle](example/build.gradle).
```groovy
dependencies {
    compile('org.springframework.boot:spring-boot-starter-actuator')
}
```

## Spring Boot Admin Client
[Spring Boot Admin](https://github.com/codecentric/spring-boot-admin) is a simple third-party, web-based admin client for monitoring Spring Boot applications.

We host a version of the (Spring Boot Admin Server)[http://ena-dev:9900/] on our development tools server.
```groovy
dependencies {
    compile('de.codecentric:spring-boot-admin-starter-client:1.3.7')
}
```

By adding a dependency on the client library and adding some basic configuration any Spring Boot app can register with the server. The server then monitors the application through the Spring Actuator endpoints.

### Spring Boot Admin Client Configuration ###
*Step 1*: Add the Spring Boot Admin Client dependency to the dependencies block in [build.gradle](example/build.gradle).

```groovy
dependencies {
    compile('de.codecentric:spring-boot-admin-starter-client:1.3.7')
}
```

*Step 2*: In [application.properties](example/src/main/resources/application.properties) add two lines:

```properties
spring.boot.admin.url=http://ena-dev:9900
spring.boot.admin.client.name=${project.name}
info.version=${version}
```
* The first is the URL of the Spring Boot Admin Server
* The second is a place holder that gets populated with the name of the project in Gradle
* The third is a place holder for the current version of the project from Gradle

*Step 3*: To make sure that the place holders get populated by Gradle we need to add the following task to [build.gradle](example/build.gradle). 
```groovy
processResources {
    filesMatching('application.properties') {
        expand(project.properties)
    }
}
```

# README.md
The project must have a [README.md](example/README.md) file in the root directory. This should contain the following:

- Synopsis: At the top of the file there should be a short introduction and/ or overview that explains **what** the project is.
- How to build
- How to run
- How to publish 
- Hot to deploy
