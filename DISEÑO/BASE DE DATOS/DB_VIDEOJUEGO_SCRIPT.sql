-- Crear la base de datos (si no existe)
DROP DATABASE IF EXISTS db_videojuego_educativo;
CREATE DATABASE db_videojuego_educativo;
USE db_videojuego_educativo;

-- Tabla de administradores (independiente)
CREATE TABLE IF NOT EXISTS tbl_administrador (
    id_administrador INT PRIMARY KEY AUTO_INCREMENT,
    nombre_usuario VARCHAR(50) NOT NULL,
    contrasena VARCHAR(255) NOT NULL
);

-- Tabla de jugadores
CREATE TABLE IF NOT EXISTS tbl_jugador (
    id_jugador INT PRIMARY KEY AUTO_INCREMENT,
    nombre_perfil VARCHAR(50) NOT NULL UNIQUE,
    tiempo_total INT DEFAULT 0,
    aciertos_totales INT DEFAULT 0,
    errores_totales INT DEFAULT 0
);

-- Tabla de preguntas (agregada columna 'estado')
CREATE TABLE IF NOT EXISTS tbl_pregunta (
    id_pregunta INT PRIMARY KEY AUTO_INCREMENT,
    texto_pregunta VARCHAR(255) NOT NULL,
    opciones TEXT NOT NULL,
    respuesta_correcta VARCHAR(50) NOT NULL,
    dificultad VARCHAR(20) NOT NULL,
    tiempo_limite INT NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    costo_energia INT NOT NULL,
    estado VARCHAR(10) NOT NULL DEFAULT 'activo', -- Nueva columna: 'activo' o 'inactivo'
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
INSERT INTO tbl_administrador (nombre_usuario, contrasena)
VALUES ('admin', 'admin123');

-- Insertar jugadores
INSERT INTO tbl_jugador (nombre_perfil, tiempo_total, aciertos_totales, errores_totales)
VALUES ('Jugador1', 300, 15, 5);

INSERT INTO tbl_jugador (nombre_perfil, tiempo_total, aciertos_totales, errores_totales)
VALUES ('Jugador2', 450, 20, 10);

-- Insertar preguntas (con estado)
INSERT INTO tbl_pregunta (texto_pregunta, opciones, respuesta_correcta, dificultad, tiempo_limite, categoria, costo_energia, estado)
VALUES 
('¿Cuál es el área de un triángulo con base 4 y altura 3?', '["6", "12", "8"]', '6', 'Fácil', 30, 'aritmética', 20, 'activo'),
('¿Cuánto es 5 + 3 * 2?', '["11", "16", "13"]', '11', 'Medio', 20, 'aritmética', 20, 'activo'),
('¿Cuál es el perímetro de un cuadrado de lado 5?', '["20", "25", "15"]', '20', 'Fácil', 25, 'aritmética', 20, 'activo'),
('¿Cuánto es 3 x 42?', '{"a": "12", "b": "10", "c": "8", "d": "6"}', 'a', 'fácil', 5, 'multiplicación', 50, 'inactivo'),
('¿Cuánto es 5 x 6?', '{"a": "30", "b": "25", "c": "20", "d": "15"}', 'a', 'fácil', 5, 'multiplicación', 10, 'activo');

-- Insertar partidas
INSERT INTO tbl_partida (id_jugador, personaje, tiempo_total_partida, aciertos_partida, errores_partida, fecha_inicio)
VALUES 
(1, 'Personaje1', 150, 8, 2, '2025-05-01 10:00:00'),
(2, 'Personaje2', 200, 7, 3, '2025-05-01 11:00:00');

-- Insertar respuestas
INSERT INTO tbl_respuesta_jugador (id_partida, id_pregunta, respuesta_dada, es_correcta, tiempo_respuesta)
VALUES 
(1, 1, '6', TRUE, 15),
(1, 2, '16', FALSE, 20),
(2, 1, '12', FALSE, 25),
(2, 3, '20', TRUE, 10);

-- Restablecer AUTO_INCREMENT
ALTER TABLE tbl_administrador AUTO_INCREMENT = 2;
ALTER TABLE tbl_jugador AUTO_INCREMENT = 3;
ALTER TABLE tbl_partida AUTO_INCREMENT = 3;
ALTER TABLE tbl_respuesta_jugador AUTO_INCREMENT = 5;
ALTER TABLE tbl_pregunta AUTO_INCREMENT = 6;