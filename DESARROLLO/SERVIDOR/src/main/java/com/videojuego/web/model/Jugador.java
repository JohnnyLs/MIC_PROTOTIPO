package com.videojuego.web.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "tbl_jugador")
@Getter
@Setter
public class Jugador {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_jugador")
    private Integer idJugador;

    @Column(name = "nombre_perfil", nullable = false, unique = true)
    private String nombrePerfil;

    @Column(name = "tiempo_total")
    private Integer tiempoTotal = 0;

    @Column(name = "aciertos_totales")
    private Integer aciertosTotales = 0;

    @Column(name = "errores_totales")
    private Integer erroresTotales = 0;

    @OneToMany(mappedBy = "jugador", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Partida> partidas = new ArrayList<>();
}