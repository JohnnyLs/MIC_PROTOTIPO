package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class TopJugadorPorCategoriaDTO {
    private String categoria;
    private List<JugadorCategoriaDTO> jugadores;

    @Getter
    @Setter
    public static class JugadorCategoriaDTO {
        private String nombrePerfil;
        private Integer aciertos;
        private Integer errores;
        private Double puntuacion;
    }
}