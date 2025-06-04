package com.videojuego.web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthCheckController {
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/api/db-healthcheck")
    public String checkDatabase() {
        jdbcTemplate.queryForObject("SELECT 1", Integer.class);
        return "Database OK";
    }
}