package com.videojuego.web.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "tbl_pregunta")
@Getter
@Setter
public class Pregunta {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_pregunta")
    private Integer idPregunta;

    @Column(name = "texto_pregunta", nullable = false)
    private String textoPregunta;

    @Column(name = "opciones", nullable = false)
    private String opciones;

    @Column(name = "respuesta_correcta", nullable = false)
    private String respuestaCorrecta;

    @Column(name = "dificultad", nullable = false)
    private String dificultad;

    @Column(name = "tiempo_limite", nullable = false)
    private Integer tiempoLimite;

    @Column(name = "categoria", nullable = false)
    private String categoria;

    @Column(name = "costo_energia", nullable = false)
    private Integer costoEnergia;

    @Column(name = "estado", nullable = false)
    private String estado = "activo";

    @OneToMany(mappedBy = "pregunta", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<RespuestaJugador> respuestas = new ArrayList<>();
}