package com.videojuego.web.repository;

import com.videojuego.web.model.RespuestaJugador;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RespuestaJugadorRepository extends JpaRepository<RespuestaJugador, Integer> {
}