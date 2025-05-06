package com.videojuego.web.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "tbl_partida")
@Getter
@Setter
public class Partida {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_partida")
    private Integer idPartida;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_jugador", nullable = false)
    private Jugador jugador;

    @Column(name = "personaje", nullable = false)
    private String personaje;

    @Column(name = "tiempo_total_partida")
    private Integer tiempoTotalPartida = 0;

    @Column(name = "aciertos_partida")
    private Integer aciertosPartida = 0;

    @Column(name = "errores_partida")
    private Integer erroresPartida = 0;

    @Column(name = "fecha_inicio", nullable = false)
    private LocalDateTime fechaInicio;

    @OneToMany(mappedBy = "partida", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<RespuestaJugador> respuestas = new ArrayList<>();
}