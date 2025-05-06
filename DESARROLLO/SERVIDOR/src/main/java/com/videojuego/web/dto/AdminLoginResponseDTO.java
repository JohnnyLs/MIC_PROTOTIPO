package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminLoginResponseDTO {
    private Integer idAdministrador;
    private String nombreUsuario;
}