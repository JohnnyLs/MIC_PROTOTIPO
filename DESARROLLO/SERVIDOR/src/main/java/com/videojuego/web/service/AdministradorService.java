package com.videojuego.web.service;

import com.videojuego.web.dto.AdminLoginRequestDTO;
import com.videojuego.web.dto.AdminLoginResponseDTO;
import com.videojuego.web.model.Administrador;
import com.videojuego.web.repository.AdministradorRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AdministradorService {

    private static final Logger logger = LoggerFactory.getLogger(AdministradorService.class);

    @Autowired
    private AdministradorRepository administradorRepository;

    @Transactional(readOnly = true)
    public AdminLoginResponseDTO login(AdminLoginRequestDTO request) {
        logger.info("Iniciando autenticación para el administrador: {}", request.getNombreUsuario());

        // Buscar el administrador por nombre de usuario
        Administrador administrador = administradorRepository.findByNombreUsuario(request.getNombreUsuario())
                .orElseThrow(() -> {
                    logger.warn("Administrador no encontrado: {}", request.getNombreUsuario());
                    return new RuntimeException("Nombre de usuario o contraseña incorrectos");
                });

        // Verificar la contraseña (comparación directa, sin encriptación)
        if (!administrador.getContrasena().equals(request.getContrasena())) {
            logger.warn("Contraseña incorrecta para el administrador: {}", request.getNombreUsuario());
            throw new RuntimeException("Nombre de usuario o contraseña incorrectos");
        }

        // Construir la respuesta
        logger.info("Autenticación exitosa para el administrador: {}", request.getNombreUsuario());
        AdminLoginResponseDTO response = new AdminLoginResponseDTO();
        response.setIdAdministrador(administrador.getIdAdministrador());
        response.setNombreUsuario(administrador.getNombreUsuario());

        return response;
    }
}