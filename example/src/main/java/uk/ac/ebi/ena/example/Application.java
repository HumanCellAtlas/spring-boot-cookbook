package uk.ac.ebi.ena.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.system.ApplicationPidFileWriter;
import org.springframework.context.annotation.Import;

@SpringBootApplication
public class Application {

    private static String PID_FILE = "ena-example.pid";

    public static void main(String[] args) throws Exception {
        SpringApplication springApplication = new SpringApplication(Application.class);
        springApplication.addListeners(new ApplicationPidFileWriter(PID_FILE));
        springApplication.run(args);
    }

}