package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateRespuestaRequestDTO {
    private Integer idPartida;
    private Integer idPregunta;
    private String respuestaDada;
    private Boolean esCorrecta;
    private Integer tiempoRespuesta;
}