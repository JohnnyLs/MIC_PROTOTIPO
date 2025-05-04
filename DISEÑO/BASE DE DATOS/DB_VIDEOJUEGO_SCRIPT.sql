-- Crear la base de datos (si no existe)
CREATE DATABASE IF NOT EXISTS db_videojuego_educativo;
USE db_videojuego_educativo;

-- Tabla base de usuarios
CREATE TABLE IF NOT EXISTS tbl_usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    tipo_usuario VARCHAR(20) NOT NULL,
    INDEX idx_usuario_tipo (tipo_usuario)
);

-- Tabla de administradores
CREATE TABLE IF NOT EXISTS tbl_administrador (
    id_administrador INT PRIMARY KEY,
    nombre_usuario VARCHAR(50) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_administrador) REFERENCES tbl_usuario(id_usuario)
);

-- Tabla de jugadores
CREATE TABLE IF NOT EXISTS tbl_jugador (
    id_jugador INT PRIMARY KEY,
    nombre_perfil VARCHAR(50) NOT NULL UNIQUE,
    tiempo_total INT DEFAULT 0,
    aciertos_totales INT DEFAULT 0,
    errores_totales INT DEFAULT 0,
    FOREIGN KEY (id_jugador) REFERENCES tbl_usuario(id_usuario)
);

-- Tabla de preguntas (sin el atributo tema, pero con categoria y costo_energia)
CREATE TABLE IF NOT EXISTS tbl_pregunta (
    id_pregunta INT PRIMARY KEY AUTO_INCREMENT,
    texto_pregunta VARCHAR(255) NOT NULL,
    opciones TEXT NOT NULL,
    respuesta_correcta VARCHAR(50) NOT NULL,
    dificultad VARCHAR(20) NOT NULL,
    tiempo_limite INT NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    costo_energia INT NOT NULL,
    INDEX idx_pregunta_dificultad (dificultad)
);

-- Tabla de partidas
CREATE TABLE IF NOT EXISTS tbl_partida (
    id_partida INT PRIMARY KEY AUTO_INCREMENT,
    id_jugador INT NOT NULL,
    personaje VARCHAR(20) NOT NULL,
    tiempo_total_partida INT DEFAULT 0,
    aciertos_partida INT DEFAULT 0,
    errores_partida INT DEFAULT 0,
    fecha_inicio DATETIME NOT NULL,
    FOREIGN KEY (id_jugador) REFERENCES tbl_jugador(id_jugador),
    INDEX idx_partida_jugador (id_jugador)
);

-- Tabla de respuestas de los jugadores
CREATE TABLE IF NOT EXISTS tbl_respuesta_jugador (
    id_respuesta INT PRIMARY KEY AUTO_INCREMENT,
    id_partida INT NOT NULL,
    id_pregunta INT NOT NULL,
    respuesta_dada VARCHAR(50) NOT NULL,
    es_correcta BOOLEAN NOT NULL,
    tiempo_respuesta INT NOT NULL,
    FOREIGN KEY (id_partida) REFERENCES tbl_partida(id_partida),
    FOREIGN KEY (id_pregunta) REFERENCES tbl_pregunta(id_pregunta),
    INDEX idx_respuesta_partida (id_partida),
    INDEX idx_respuesta_pregunta (id_pregunta)
);

-- Insertar administrador
INSERT IGNORE INTO tbl_usuario (id_usuario, tipo_usuario) VALUES (1, 'Administrador');
INSERT IGNORE INTO tbl_administrador (id_administrador, nombre_usuario, contrasena)
VALUES (1, 'admin', 'admin123');

-- Insertar jugadores
INSERT IGNORE INTO tbl_usuario (id_usuario, tipo_usuario) VALUES (2, 'Jugador');
INSERT IGNORE INTO tbl_jugador (id_jugador, nombre_perfil, tiempo_total, aciertos_totales, errores_totales)
VALUES (2, 'Jugador1', 300, 15, 5);

INSERT IGNORE INTO tbl_usuario (id_usuario, tipo_usuario) VALUES (3, 'Jugador');
INSERT IGNORE INTO tbl_jugador (id_jugador, nombre_perfil, tiempo_total, aciertos_totales, errores_totales)
VALUES (3, 'Jugador2', 450, 20, 10);

-- Insertar preguntas (sin tema, pero con categoria y costo_energia)
INSERT IGNORE INTO tbl_pregunta (id_pregunta, texto_pregunta, opciones, respuesta_correcta, dificultad, tiempo_limite, categoria, costo_energia)
VALUES 
(1, '¿Cuál es el área de un triángulo con base 4 y altura 3?', '["6", "12", "8"]', '6', 'Fácil', 30, 'aritmética', 20),
(2, '¿Cuánto es 5 + 3 * 2?', '["11", "16", "13"]', '11', 'Medio', 20, 'aritmética', 20),
(3, '¿Cuál es el perímetro de un cuadrado de lado 5?', '["20", "25", "15"]', '20', 'Fácil', 25, 'aritmética', 20),
(4, '¿Cuánto es 3 x 42?', '{"a": "12", "b": "10", "c": "8", "d": "6"}', 'a', 'fácil', 5, 'multiplicación', 50),
(5, '¿Cuánto es 5 x 6?', '{"a": "30", "b": "25", "c": "20", "d": "15"}', 'a', 'fácil', 5, 'multiplicación', 10);

-- Insertar partidas
INSERT IGNORE INTO tbl_partida (id_partida, id_jugador, personaje, tiempo_total_partida, aciertos_partida, errores_partida, fecha_inicio)
VALUES 
(1, 2, 'Personaje1', 150, 8, 2, '2025-05-01 10:00:00'),
(2, 3, 'Personaje2', 200, 7, 3, '2025-05-01 11:00:00');

-- Insertar respuestas
INSERT IGNORE INTO tbl_respuesta_jugador (id_respuesta, id_partida, id_pregunta, respuesta_dada, es_correcta, tiempo_respuesta)
VALUES 
(1, 1, 1, '6', TRUE, 15),
(2, 1, 2, '16', FALSE, 20),
(3, 2, 1, '12', FALSE, 25),
(4, 2, 3, '20', TRUE, 10);

-- Vista para el administrador con toda la información completa de cada partida (sin tema)
CREATE OR REPLACE VIEW vista_reporte_completo AS
SELECT 
    p.id_partida,
    j.nombre_perfil AS jugador,
    p.tiempo_total_partida,
    p.aciertos_partida,
    p.errores_partida,
    p.fecha_inicio,
    p.personaje,
    rj.id_respuesta,
    pr.texto_pregunta,
    pr.dificultad,
    pr.categoria,
    rj.respuesta_dada,
    rj.es_correcta,
    rj.tiempo_respuesta
FROM tbl_partida p
JOIN tbl_jugador j ON p.id_jugador = j.id_jugador
LEFT JOIN tbl_respuesta_jugador rj ON p.id_partida = rj.id_partida
LEFT JOIN tbl_pregunta pr ON rj.id_pregunta = pr.id_pregunta;