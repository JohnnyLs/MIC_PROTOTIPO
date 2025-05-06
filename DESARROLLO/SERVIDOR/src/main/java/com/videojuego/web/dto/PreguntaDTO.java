package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PreguntaDTO {
    private Integer idPregunta;
    private String textoPregunta;
    private String opciones;
    private String respuestaCorrecta;
    private String dificultad;
    private Integer tiempoLimite;
    private String categoria;
    private Integer costoEnergia;
    private String estado; // 'activo' o 'inactivo'
}