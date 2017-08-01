# ENA Spring Boot Microservices Cookbook

This project sets out guidelines and recipies to enable Spring Boot based projects developed within ENA to be consistent and easy to deploy and manage.

* [Gradle](#gradle)
  * [Basics](#basics)
    * [Name](#name)
    * [Group Name](#group-name)
    * [Version](#version)
    * [Source Compatibility](#source-compatibility)
    * [Repositories](#repositories)
  * [Plugins](#plugins)
    * [Java Plugin](#java-plugin)
    * [Jacoco Plugin](#jacoco-plugin)
    * [Maven-publish Plugin](#maven-publish-plugin)
    * [Spring Boot Plugin](#spring-boot-plugin)
    * [SonarQube Plugin](#sonarqube-plugin)
    * [SSH Plugin](#ssh-plugin)
  * [Gradle Wrapper](#gradle-wrapper)
  * [Dependencies](#dependencies)
    * [Spring Boot Starter Web](#spring-boot-starter-web)
    * [Spring Boot Starter Test](#spring-boot-starter-test)
  * [Publication](#publication)
    * [Manifest](#manifest)
    * [sourceJar](#sourcejar)
    * [Artifactory Publishing](#artifactory-publishing)
  * [gradle.properties](#gradle.properties)
* [Java Application](#java-application)
  * [Application.java](#application.java)
* [Documentation](#documentation)
  * [Swagger 2](#swagger-2)
* [Monitoring](#monitoring)
  * [Spring Boot Actuator](#spring-boot-actuator)
  * [Spring Boot Admin Client](#spring-boot-admin-client)
          * [Spring Boot Admin Client Configuration](#spring-boot-admin-client-configuration)
* [Logging](#logging)
      * [Graylog Logging Configuration](#graylog-logging-configuration)
* [Multiple Profiles](#multiple-profiles)
  * [Specifying Active Profile in Gradle](#specifying-active-profile-in-gradle)
* [Deployment](#deployment)
  * [Configuring ports and paths](#configuring-ports-and-paths)
  * [Deployment Script](#deployment-script)
  * [Execution Script](#execution-script)
  * [Monit](#monit)
* [ena-example](#ena-example)
  * [Gradle Configuration](#gradle-configuration)
* [Scripts](#scripts)
  * [Run Locally](#run-locally)
* [!/usr/bin/env bash](#!/usr/bin/env-bash)
  * [Sonar](#sonar)
* [!/usr/bin/env bash](#!/usr/bin/env-bash)
  * [Publish](#publish)
* [!/usr/bin/env bash](#!/usr/bin/env-bash)
  * [Deploy](#deploy)
* [!/usr/bin/env bash](#!/usr/bin/env-bash)
* [README.md](#readme.md)
dulcinea:spring-boot-cookbook dvaughan$ ruby toc-generator.rb 
* [ENA Spring Boot Microservices Cookbook](#ena-spring-boot-microservices-cookbook)
* [Gradle](#gradle)
  * [Basics](#basics)
    * [Name](#name)
    * [Group Name](#group-name)
    * [Version](#version)
    * [Source Compatibility](#source-compatibility)
    * [Repositories](#repositories)
  * [Plugins](#plugins)
    * [Java Plugin](#java-plugin)
    * [Jacoco Plugin](#jacoco-plugin)
    * [Maven-publish Plugin](#maven-publish-plugin)
    * [Spring Boot Plugin](#spring-boot-plugin)
    * [SonarQube Plugin](#sonarqube-plugin)
    * [SSH Plugin](#ssh-plugin)
  * [Gradle Wrapper](#gradle-wrapper)
  * [Dependencies](#dependencies)
    * [Spring Boot Starter Web](#spring-boot-starter-web)
    * [Spring Boot Starter Test](#spring-boot-starter-test)
  * [Publication](#publication)
    * [Manifest](#manifest)
    * [sourceJar](#sourcejar)
    * [Artifactory Publishing](#artifactory-publishing)
  * [gradle.properties](#gradle.properties)
* [Java Application](#java-application)
  * [Application.java](#application.java)
  * [ExitCodeGenerator](#exitcodegenerator)
* [Documentation](#documentation)
  * [Swagger 2](#swagger-2)
* [Monitoring](#monitoring)
  * [Spring Boot Actuator](#spring-boot-actuator)
  * [Spring Boot Admin Client](#spring-boot-admin-client)
          * [Spring Boot Admin Client Configuration](#spring-boot-admin-client-configuration)
* [Logging](#logging)
      * [Graylog Logging Configuration](#graylog-logging-configuration)
* [Multiple Profiles](#multiple-profiles)
  * [Specifying Active Profile in Gradle](#specifying-active-profile-in-gradle)
* [Deployment](#deployment)
  * [Configuring ports and paths](#configuring-ports-and-paths)
  * [Deployment Script](#deployment-script)
  * [Execution Script](#execution-script)
  * [Monit](#monit)
* [ena-example](#ena-example)
  * [Gradle Configuration](#gradle-configuration)
* [Scripts](#scripts)
  * [Run Locally](#run-locally)
* [!/usr/bin/env bash](#!/usr/bin/env-bash)
  * [Sonar](#sonar)
* [!/usr/bin/env bash](#!/usr/bin/env-bash)
  * [Publish](#publish)
* [!/usr/bin/env bash](#!/usr/bin/env-bash)
  * [Deploy](#deploy)
* [!/usr/bin/env bash](#!/usr/bin/env-bash)
* [README.md](#readme.md)

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
## ExitCodeGenerator

If you want to use [ExitCodeGenerator](http://docs.spring.io/autorepo/docs/spring-boot/current/api/org/springframework/boot/ExitCodeGenerator.html) or lifecycle annotations such as @PreDestroy to cleanup resources (e.g. thread pools), then Spring Boot needs to manage the application exit process.

We can enable this by adding SpringApplication.exit:

```java
public static void main(String[] args) throws Exception {
    SpringApplication springApplication = new SpringApplication(Application.class);
    springApplication.addListeners(new ApplicationPidFileWriter(PID_FILE));
    SpringApplication.exit(springApplication.run(args));
}
```

This is particularly important for LSF processes, cron jobs, or command-line based applications.

# Documentation
Any APIs must provide documentation. One way of doing this is using Swagger.

## Swagger 2
[Swagger](https://swagger.io/) generates a webpages for documenting and testing a REST API.

It has two dependencies, one provides a REST endpoint for documentation and the other a standard UI on top of it.

Add these dependencies into the dependencies block in [build.gradle](example/build.gradle).

```groovy
dependencies {
    compile('io.springfox:springfox-swagger2:2.+')
    compile('io.springfox:springfox-swagger-ui:2.+')
}
```

Swagger then requires configuration in the application. An example is shown in [SwaggerConfig.java](example/src/main/java/uk/ac/ebi/ena/example/SwaggerConfig.java).

One applied Swagger will generate a REST endpoint at /v2/api-docs and an interface will be available at /swagger-ui.html at the root URL of the application. 

By default this will include all public end points so Spring management endpoints will be included as well as our own.

For example the example application has:
* A Swagger API endpoint available at [http://localhost:1234/example/v2/api-docs](http://localhost:1234/example/v2/api-docs).
* A Swagger UI available at [http://localhost:1234/example/swagger-ui.html](http://localhost:1234/example/swagger-ui.html).

A short tutotial covering more configuration options can be found [here](http://www.baeldung.com/swagger-2-documentation-for-spring-rest-api).

# Monitoring

## Spring Boot Actuator
[Spring Boot Actuator](https://spring.io/guides/gs/actuator-service/) includes a number of additional features to help us monitor and manage our applications. These include the health of the application and memory usage as examples.

To add it we need to add the dependency into the dependencies block in [build.gradle](example/build.gradle).
```groovy
dependencies {
    compile('org.springframework.boot:spring-boot-starter-actuator')
}
```

In recent version of Spring Boot [the actuator requires authentication by default](https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-monitoring.html ). 
If we are Spring Security in our project we can configure this however if not, and we want to make the actuator endpoints available we need to disable management security by adding this line to [application.properties](example/src/main/resources/application.properties).
```
management.security.enabled=false
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

*Step 2*: In [application.properties](example/src/main/resources/application.properties) add three lines:
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
# Logging
We have a [Graylog server](http://ena-log:9000/search) that acts a a repository for all our log messages so we can have a single view into the workings of the whole system.

By default Spring Boot provides Logback for logging. This is made available through the [SLF4J](https://www.slf4j.org/) abstraction.
## Graylog Logging Configuration ##
*Step 1*: Add the Logback GELF dependency. This enables Logback messages to be converted into GELF format and sent to the Graylog server. Add the dependency to the dependencies block in [build.gradle](example/build.gradle).
```groovy
dependencies {
    compile('de.siegmar:logback-gelf:1.0.4')
}
```
*Step 2*: Add the [logback-spring.xml](example/src/main/resources/logback-spring.xml) configuration file to the project's [src/main/resources](example/src/main/resources). This file is pre-configured with the correct settings for our internal Graylog server.

*Step 3*: Add the following line into [application.properties](example/src/main/resources/application.properties) to define the file name and path of the local logging file to store on the server.
```properties
logging.file=logs/${project.name}.log
```

*WARNING* The Spring Boot runner in Intellj does not process resources so ${project.name} is unpopulated causing logging to error. Please run at the command line using:
```
./gradlew bootRun
```

# Multiple Profiles
Most projects will require different configuration when they are in development or deployed to the dev, test or prod servers. For this we use Spring profiles.

We use create a application.properties file postfixed with the profile name for each profile:
* [application-default.properties](example/src/main/resources/application-default.properties) - Used by default in development
* [application-dev.properties](example/src/main/resources/application-dev.properties) - Deployed to development server
* [application-test.properties](example/src/main/resources/application-test.properties) - Deployed to test server
* [application-prod.properties](example/src/main/resources/application-prod.properties) - Deployed to production server

In typical applications the applications.properties file for each profile may define environment specific database connection for example.

In the example application we use them contain the following:

```properties
info.profile=test
logging.level.root=WARN
logging.level.org.springframework.web=WARN
logging.level.uk.ac.ebi.ena=INFO
``` 
info.profile is used to show the environment when the application is shown in the [Spring Boot Admin](https://github.com/codecentric/spring-boot-admin) console.

The logging level lines are used to define the logging levels for each environment. For example in development we may wish to have more verbose logging than in production.

In the [application-default.properties](example/src/main/resources/application-default.properties) we also add the following line:
```properties
spring.boot.admin.auto-deregistration=true
```
This tells the Spring Boot Admin Server to remove the application from the list when it closes to stop the list becoming cluttered with closed, temporary instances of the application.

## Specifying Active Profile in Gradle

When running an application from the command line using Gradle specifying the active profile as a parameter does not work as we may expect.

For example the following may execute with the default profile instead of dev:

```bash
./gradlew bootRun -Dspring.profiles.active=dev
```

To enable Gradle to recognize the command line parameter add the following line in [build.gradle](example/build.gradle):

```groovy
bootRun.systemProperties = System.properties
```

# Deployment
Deployment involves calling a script on the target server with parameter. Each server has on it two standard scripts.

## Configuring ports and paths
If deployment is to a shared VM so it is important to define a port and url for the application so it does not clash with others.

To do this we add the following lines to [application.properties](example/src/main/resources/application.properties):
```properties
server.port=1234
server.contextPath=/example
```
This sets the application to run on port 1234 and to have a base url of /example.

If this was run locally the web address would be:
[http://localhost:1234/example](http://localhost:1234/example)

## Deployment Script
[generic-deploy.sh](server-scripts/generic-deploy.sh) 
This script may be called on the server from deploying previous versions but it would normally be called by the deploy tasks in Gradle.

It takes the following parameters:
* name of the application to deploy
* version of to deploy
* port the application is set to run on
* url path the application will be deployed to

For example to deploy ena-example version 1.0.0 running on port 1234 at a url of /example the call to the script on the server would be:
```bash
./generic-deploy.sh ena-example 1.0.0 1234 example
```
The script then does the following:
* Downloads the correct version of the jar from Artifactory.
* Checks the the jar is above 10MB.
* Creates a symbolic link between ena-<name>-current.jar and the versioned jar.
* Restarts the application process using Monit.
* Expands the META-INF/MANIFEST.MF of the deployed jar and checks the version matches the required version.
* Waits 10 seconds.
* Requests the applications health and info endpoints and displays the results.

If any of these steps fail an error message will be displayed and the script will go no further. If Monit has not been set up the script will prompt with the correct Monit configuration.

## Execution Script
[generic-control.sh](server-scripts/generic-control.sh) is used by Monit to start and stop the application. 
This script should not be needed to be run manually as it is meant for calling by Monit.

It takes three parameters
* Action (start|stop)
* name of application
* environment (Spring profile to use)

For example to start the ena-example application in test configuration use:
```bash
./generic-control.sh ena-example test
```

## Monit
Monit needs to be configured to be able to monitor the process of the application and start the application if it becomes unavaliable. For the example application the section to add to the .monitrc file on a dev server is:
```
# ena-example
check process ena-example with pidfile /net/isilonP/public/rw/homes/ena_adm/ena/ena-example/ena-example.pid
   group ena-example
   start program = "/net/isilonP/public/rw/homes/ena_adm/ena/generic-control.sh start ena-example dev"
   stop program = "/net/isilonP/public/rw/homes/ena_adm/ena/generic-control.sh stop ena-example dev"
   if not exist then start
   if failed host localhost port 1234 protocol http and request "/example" with timeout 10 seconds for 5 cycles
       then restart
```

## Gradle Configuration
We configure the [build.gradle](example/build.gradle) file to call the [Deployment Script](#deployment-script) script on each server using the [SSH Plugin](#ssh-plugin).

*Step 1* We add a block to define all the remote servers. It is assumed that the local machine is configured with an ssh key capabable of logging into each server.
```groovy
remotes {
    dev {
        host = 'ves-ebi-5b'
        user = 'ena_adm'
        identity = file("${System.properties['user.home']}/.ssh/id_rsa")
    }
    test {
        host = 'ves-ebi-5a'
        user = 'ena_adm'
        identity = file("${System.properties['user.home']}/.ssh/id_rsa")
    }
    prodA {
        host = 'ves-hx-5a'
        user = 'ena_adm'
        identity = file("${System.properties['user.home']}/.ssh/id_rsa")
    }
    prodB {
        host = 'ves-hx-5b'
        user = 'ena_adm'
        identity = file("${System.properties['user.home']}/.ssh/id_rsa")
    }
}
```

*Step 2* We then add tasks to call the [Deployment Script] on each server specifying the correct environment port and base url path.
```groovy
task deployToDev << {
    ssh.run {
        session(remotes.dev) {
            execute "~/ena/generic-deploy.sh $project.name $version dev 1234 example"
        }
    }
}

task deployToTest << {
    ssh.run {
        session(remotes.test) {
            execute "~/ena/generic-deploy.sh $project.name $version test 1234 example"
        }
    }
}

task deployToProd << {
    ssh.run {
        session(remotes.prodA) {
            execute "~/ena/generic-deploy.sh $project.name $version prod 1234 example"
        }
    }
    ssh.run {
        session(remotes.prodB) {
            execute "~/ena/generic-deploy.sh $project.name $version prod 1234 example"
        }
    }
}
```

# Continuous Integration
All projects should support Continuous Integration to ensure the code that is pushed to git builds correctly and passes all test.

For private projects we use our internal [Jenkins server](http://ena-dev:8080/jenkins) to checkout and build the project after each push.

For public projects we can use [Travis](https://travis-ci.org), a web based CI service.

## Configuring Travis
Travis requires a file named .travis.yml in the root of the project. This tells Travis information need to build the projec such as the language used.

An example is [.travis,yml](.travis.yml)

# Scripts
It is useful to create a number of command line scripts to simplify the processes for developers.

## Run Locally
[run-locally.sh](example/run-locally.sh)
```bash
#!/usr/bin/env bash
./gradlew bootRun
```
Runs the application locally using Spring Boot.
## Sonar
```bash
#!/usr/bin/env bash
./gradlew clean build sonar
```
Performs Sonar inspections on the code.

## Publish
```bash
#!/usr/bin/env bash
./gradlew clean build publish
```
Builds the artifact and deploys to Artifactory.

## Deploy
There are also several deployment scripts which build, publish and deploy to an single environment.
* [deploy-to-dev.sh](example/deploy-to-dev.sh)
* [deploy-to-test.sh](example/deploy-to-test.sh)
* [deploy-to-prod.sh](example/deploy-to-prod.sh)

There is then a [deploy-all.sh](example/deploy-all.sh) that deploys to all environments.
```bash
#!/usr/bin/env bash
./gradlew clean build sonar publish deployToDev deployToTest deployToProd
```

# README.md
The project must have a [README.md](example/README.md) file in the root directory. This should contain the following:

- Synopsis: At the top of the file there should be a short introduction and/ or overview that explains **what** the project is.
- How to build
- How to run
- How to publish 
- Hot to deploy
