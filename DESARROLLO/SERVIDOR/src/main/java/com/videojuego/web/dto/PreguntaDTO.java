package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Map;

@Getter
@Setter
public class PreguntaDTO {
    private String pregunta;
    private Map<String, String> opciones;
    private String respuestaCorrecta;
    private String dificultad;
    private String categoria;
    private Integer tiempoLimite;
    private Integer costeEnergia;
}