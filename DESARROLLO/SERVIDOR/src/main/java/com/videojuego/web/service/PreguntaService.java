package com.videojuego.web.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.videojuego.web.dto.PreguntaDTO;
import com.videojuego.web.model.Pregunta;
import com.videojuego.web.repository.PreguntaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

@Service
public class PreguntaService {

    @Autowired
    private PreguntaRepository preguntaRepository;

    @Autowired
    private ObjectMapper objectMapper;

    public List<Pregunta> findAll() {
        return preguntaRepository.findAll();
    }

    public Pregunta findById(Integer id) {
        return preguntaRepository.findById(id).orElse(null);
    }

    public Pregunta save(Pregunta pregunta) {
        return preguntaRepository.save(pregunta);
    }

    public void deleteById(Integer id) {
        preguntaRepository.deleteById(id);
    }

    public Pregunta saveFromDTO(PreguntaDTO preguntaDTO) {
        Pregunta pregunta = new Pregunta();
        pregunta.setTextoPregunta(preguntaDTO.getPregunta());
        try {
            String opcionesJson = objectMapper.writeValueAsString(preguntaDTO.getOpciones());
            pregunta.setOpciones(opcionesJson);
        } catch (Exception e) {
            throw new RuntimeException("Error al convertir opciones a JSON", e);
        }
        pregunta.setRespuestaCorrecta(preguntaDTO.getRespuestaCorrecta());
        pregunta.setDificultad(preguntaDTO.getDificultad());
        pregunta.setCategoria(preguntaDTO.getCategoria());
        pregunta.setTiempoLimite(preguntaDTO.getTiempoLimite());
        pregunta.setCostoEnergia(preguntaDTO.getCosteEnergia());
        return preguntaRepository.save(pregunta);
    }

    public List<Pregunta> getRandomPreguntas(int count) {
        List<Pregunta> preguntas = findAll();
        if (preguntas.isEmpty()) {
            return Collections.emptyList();
        }
        // Mezclar las preguntas y tomar las primeras "count" (máximo 10)
        Collections.shuffle(preguntas, new Random());
        return preguntas.stream()
                .limit(Math.min(count, preguntas.size()))
                .collect(Collectors.toList());
    }
}