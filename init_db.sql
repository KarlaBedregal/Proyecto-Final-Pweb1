-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS usuarios_db;

-- Crear el usuario con la contraseña
CREATE USER 'user'@'localhost' IDENTIFIED BY 'mi_password';

-- Conceder privilegios al usuario en la base de datos usuarios_db
GRANT ALL PRIVILEGES ON usuarios_db.* TO 'user'@'%';

-- Asegurarse de que los privilegios se apliquen correctamente
FLUSH PRIVILEGES;

-- Seleccionar la base de datos
USE usuarios_db;

-- Crear la tabla usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    apellidos VARCHAR(100),
    nombre_usuario VARCHAR(50) UNIQUE,
    edad INT,
    genero VARCHAR(10),
    telefono VARCHAR(15),
    correo VARCHAR(100) UNIQUE,
    contrasena VARCHAR(255),
    contrasena_confirmacion VARCHAR(255)
);
