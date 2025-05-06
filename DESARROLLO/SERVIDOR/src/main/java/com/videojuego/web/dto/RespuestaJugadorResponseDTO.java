package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class RespuestaJugadorResponseDTO {
    private Integer idRespuesta;
    private Integer idPartida;
    private String nombrePerfil;
    private String personaje;
    private Integer idPregunta;
    private String textoPregunta;
    private String opciones;
    private String respuestaCorrecta;
    private String respuestaDada;
    private Boolean esCorrecta;
    private Integer tiempoRespuesta;
    private LocalDateTime fechaInicio;
}