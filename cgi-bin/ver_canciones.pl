#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use File::Spec;
use utf8;

my $cgi = CGI->new;
my $directorio = $cgi->param('directorio') || 'Mis favoritos';
my $path = File::Spec->catfile('/descargas', $directorio);

print $cgi->header('text/html; charset=UTF-8');

print <<EOF;
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Canciones</title>
    <link rel="stylesheet" href="/var/www/html/estilosdescargador.css">
    <style>
    body {
        font-family: Arial, sans-serif;
        background-color: #ffffff;
        margin: 0;
        padding: 0;
        height: 100vh; /* Asegura que el cuerpo ocupe toda la altura de la ventana */
        display: flex;
        align-items: center; /* Centra verticalmente */
        flex-direction: column; /* Para que todo esté alineado en columna */
    }

    * {
        box-sizing: border-box; /* Ajusta el tamaño para todos los elementos */
    }

    h1 {
        font-size: 3rem;
        color: #4facfe;
        margin-bottom: 50px; 
        text-align: center; /* Alinea el título al centro */
    }

    h2 {
        font-size: 2rem;
        color: #000;
        margin-bottom: 50px; 
        text-align: center; /* Alinea el título al centro */
    }

    label {
        color: #2e2708ab; /* Cambia el color del texto */
        font-size: 16px; /* Tamaño de fuente opcional */
        margin-bottom: 5px; /* Espaciado opcional */
        display: block; /* Asegura que el label ocupe toda la línea */
    }

    form {
        width: 100%;
        max-width: 400px; /* Tamaño máximo del formulario */
        padding: 20px;
        border-radius: 20px;
        background-color: rgba(255, 255, 255, 0); /* Fondo semitransparente */
        border: 1px solid #1c1c1c00;
    }

    .input-group {
        display: flex;
        justify-content: space-between;
        margin-bottom: 20px;
    }

    .input-group div {
        width: 48%;
    }

    input[type="text"], 
    input[type="password"], 
    input[type="email"], 
    input[type="date"], 
    input[type="number"], 
    input[type="tel"],
    select {
        width: 100%;
        padding: 10px;
        margin-bottom: 20px;
        border: 1px solid #382a1c; /* Cambia el color del borde */
        border-radius: 30px;
        background-color: rgba(158, 103, 48, 0); /* Cambia el color de fondo si lo deseas */
        color: #1b1b1b; /* Cambia el color del texto */
    }

    /* Estilo cuando el campo está en foco (al hacer clic) */
    input[type="text"]:focus, 
    input[type="password"]:focus, 
    input[type="email"]:focus, 
    input[type="date"]:focus, 
    input[type="number"]:focus, 
    select:focus {
        border-color: #33b819; /* Cambia el borde al hacer foco */
        outline: none; /* Elimina el contorno predeterminado */
    }

    input[type="submit"] {
        background-color: #6dd436;
        color: white;
        padding: 12px 18px; /* Aumenté el padding para hacerlo más grande */
        border: none;
        border-radius: 8px; /* Bordes más redondeados */
        cursor: pointer;
        width: 100%;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); /* Agregué sombra */
        transition: all 0.3s ease; /* Transición suave para hover */

        button {
            margin: 5px;
        }

        /* Estilos de los botones al final */
        div button {
            padding: 10px 20px;
            background-color: #6dd436;
            border: none;
            border-radius: 8px;
            color: white;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        div button:hover {
            background-color: #4caf50; /* Cambio de color al pasar el mouse */
        }
    }
</style>

</head>

<body>
<div class="contenedor-flex">
EOF

print "<h1>Historial de conversiones</h1><br>";
print "<h2>Canciones Descargadas en '$directorio'</h2>";

opendir(my $dh, $path) or die "No se pudo abrir el directorio '$path': $!";
my @files = readdir($dh);
closedir($dh);

print "<ul>";
foreach my $file (@files) {
    next if $file =~ /^\./; # Omitir archivos ocultos
    print "<li>$file</li>";
}
print "</ul>";

print "<button onclick='history.go(-2)'>Regresar</button>";

print "</div>";

print $cgi->end_html;

