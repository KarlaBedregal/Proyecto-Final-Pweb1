-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS mi_base_de_datos;

CREATE USER IF NOT EXISTS 'mi_usuario'@'localhost' IDENTIFIED BY 'mi_contraseña';
GRANT ALL PRIVILEGES ON mi_base_de_datos.* TO 'mi_usuario'@'localhost';
FLUSH PRIVILEGES;

-- Usar la base de datos recién creada
USE mi_base_de_datos;

-- Crear la tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear la tabla de canciones descargadas (relacionada con los usuarios)
CREATE TABLE IF NOT EXISTS canciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre_cancion VARCHAR(255) NOT NULL,
    url VARCHAR(255) NOT NULL,
    formato VARCHAR(10) NOT NULL,
    fecha_descarga TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE ON UPDATE CASCADE
);
