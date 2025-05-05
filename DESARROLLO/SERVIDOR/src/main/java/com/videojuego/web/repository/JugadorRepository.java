package com.videojuego.web.repository;

import com.videojuego.web.model.Jugador;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface JugadorRepository extends JpaRepository<Jugador, Integer> {
    Optional<Jugador> findByNombrePerfil(String nombrePerfil);
}