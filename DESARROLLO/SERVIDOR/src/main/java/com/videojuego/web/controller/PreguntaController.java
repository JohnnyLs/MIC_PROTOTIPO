package com.videojuego.web.controller;

import com.videojuego.web.dto.PreguntaDTO;
import com.videojuego.web.model.Pregunta;
import com.videojuego.web.service.PreguntaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/preguntas")
public class PreguntaController {

    @Autowired
    private PreguntaService preguntaService;

    @GetMapping
    public List<Pregunta> getAllPreguntas() {
        return preguntaService.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Pregunta> getPreguntaById(@PathVariable Integer id) {
        Pregunta pregunta = preguntaService.findById(id);
        return pregunta != null ? ResponseEntity.ok(pregunta) : ResponseEntity.notFound().build();
    }

    @PostMapping
    public Pregunta createPregunta(@RequestBody PreguntaDTO preguntaDTO) {
        return preguntaService.saveFromDTO(preguntaDTO);
    }

    @PostMapping("/bulk")
    public ResponseEntity<Void> createPreguntasBulk(@RequestBody List<PreguntaDTO> preguntasDTO) {
        for (PreguntaDTO preguntaDTO : preguntasDTO) {
            preguntaService.saveFromDTO(preguntaDTO);
        }
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<Pregunta> updatePregunta(@PathVariable Integer id, @RequestBody Pregunta preguntaDetails) {
        Pregunta pregunta = preguntaService.findById(id);
        if (pregunta == null) {
            return ResponseEntity.notFound().build();
        }
        pregunta.setTextoPregunta(preguntaDetails.getTextoPregunta());
        pregunta.setOpciones(preguntaDetails.getOpciones());
        pregunta.setRespuestaCorrecta(preguntaDetails.getRespuestaCorrecta());
        pregunta.setDificultad(preguntaDetails.getDificultad());
        pregunta.setTiempoLimite(preguntaDetails.getTiempoLimite());
        pregunta.setCategoria(preguntaDetails.getCategoria());
        pregunta.setCostoEnergia(preguntaDetails.getCostoEnergia());
        return ResponseEntity.ok(preguntaService.save(pregunta));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePregunta(@PathVariable Integer id) {
        Pregunta pregunta = preguntaService.findById(id);
        if (pregunta == null) {
            return ResponseEntity.notFound().build();
        }
        preguntaService.deleteById(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/random/10")
    public ResponseEntity<List<Pregunta>> getRandomPreguntas() {
        List<Pregunta> preguntas = preguntaService.getRandomPreguntas(10);
        return preguntas.isEmpty() ? ResponseEntity.noContent().build() : ResponseEntity.ok(preguntas);
    }
}