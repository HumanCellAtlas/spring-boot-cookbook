package uk.ac.ebi.ena.example.controllers;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ExampleController {

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String greet() {
        return "Hello this is the ENA example Spring Boot application";
    }
}
