package com.videojuego.web.controller;

import com.videojuego.web.dto.AdminLoginRequestDTO;
import com.videojuego.web.dto.AdminLoginResponseDTO;
import com.videojuego.web.service.AdministradorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
public class AdministradorController {

    @Autowired
    private AdministradorService administradorService;

    @PostMapping("/login")
    public ResponseEntity<AdminLoginResponseDTO> login(@RequestBody AdminLoginRequestDTO request) {
        AdminLoginResponseDTO response = administradorService.login(request);
        return ResponseEntity.ok(response);
    }
}