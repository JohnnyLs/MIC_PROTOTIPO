package com.videojuego.web.config;

public class JugadorNotFoundException extends RuntimeException {
    public JugadorNotFoundException(String message) {
        super(message);
    }
}