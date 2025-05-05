package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ResponderPreguntaRequestDTO {
    private Integer idPartida;
    private Integer idPregunta;
    private String respuestaDada;
    private Integer tiempoRespuesta;
}