package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminLoginRequestDTO {
    private String nombreUsuario;
    private String contrasena;
}