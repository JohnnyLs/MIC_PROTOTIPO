package com.videojuego.web.controller;

import com.videojuego.web.dto.PreguntaDTO;
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

    // Crear una pregunta
    @PostMapping
    public ResponseEntity<PreguntaDTO> crearPregunta(@RequestBody PreguntaDTO request) {
        PreguntaDTO pregunta = preguntaService.crearPregunta(request);
        return ResponseEntity.ok(pregunta);
    }

    // Obtener todas las preguntas
    @GetMapping
    public ResponseEntity<List<PreguntaDTO>> obtenerTodasLasPreguntas() {
        List<PreguntaDTO> preguntas = preguntaService.obtenerTodasLasPreguntas();
        return ResponseEntity.ok(preguntas);
    }

    // Obtener una pregunta por ID
    @GetMapping("/{id}")
    public ResponseEntity<PreguntaDTO> obtenerPreguntaPorId(@PathVariable Integer id) {
        PreguntaDTO pregunta = preguntaService.obtenerPreguntaPorId(id);
        return ResponseEntity.ok(pregunta);
    }

    // Actualizar una pregunta
    @PutMapping("/{id}")
    public ResponseEntity<PreguntaDTO> actualizarPregunta(@PathVariable Integer id, @RequestBody PreguntaDTO request) {
        PreguntaDTO pregunta = preguntaService.actualizarPregunta(id, request);
        return ResponseEntity.ok(pregunta);
    }

    // Eliminar una pregunta
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarPregunta(@PathVariable Integer id) {
        preguntaService.eliminarPregunta(id);
        return ResponseEntity.ok().build();
    }

    // Obtener preguntas aleatorias (restaurado)
    @GetMapping("/random/{cantidad}")
    public ResponseEntity<List<PreguntaDTO>> obtenerPreguntasAleatorias(@PathVariable Integer cantidad) {
        List<PreguntaDTO> preguntas = preguntaService.obtenerPreguntasAleatorias(cantidad);
        return ResponseEntity.ok(preguntas);
    }
}