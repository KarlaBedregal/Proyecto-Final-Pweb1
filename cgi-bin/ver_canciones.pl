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
        background-color: #f4f4f4;
        margin: 0;
        padding: 0;
        height: 100vh;
        display: flex;
        align-items: center;
        flex-direction: column;
    }

    * {
        box-sizing: border-box;
    }

    h1 {
        font-size: 3rem;
        color: #4facfe;
        margin-bottom: 20px;
        text-align: center;
        text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
    }

    h2 {
        font-size: 2rem;
        color: #333;
        margin-bottom: 30px;
        text-align: center;
    }

    table {
        width: 80%;
        margin: 20px auto;
        border-collapse: collapse;
        background-color: #fff;
        border-radius: 10px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }

    table th, table td {
        padding: 12px 20px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }

    table th {
        background-color: #4facfe;
        color: white;
    }

    table tr:hover {
        background-color: #f1f1f1;
    }

    button {
        background-color: #6dd436;
        color: white;
        padding: 12px 18px;
        border: none;
        border-radius: 8px;
        cursor: pointer;
        width: 200px;
        margin-top: 20px;
        display: block;
        margin-left: auto;
        margin-right: auto;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        transition: all 0.3s ease;
    }

    button:hover {
        background-color: #4caf50;
    }

    button:active {
        transform: scale(0.98);
    }

    </style>

</head>

<body>

<div class="contenedor-flex">

EOF

print "<h1>Historial de conversiones</h1>";
print "<h2>Canciones Descargadas</h2>";

opendir(my $dh, $path) or die "No se pudo abrir el directorio '$path': $!";
my @files = readdir($dh);
closedir($dh);

# Iniciamos la tabla
print "<table>";
print "<tr><th>Nombre del Archivo</th><th>Acciones</th></tr>";

# Recorremos los archivos y los imprimimos en la tabla
foreach my $file (@files) {
    next if $file =~ /^\./; # Omitir archivos ocultos
    print "<tr><td>$file</td><td><a href='/descargas/$directorio/$file' target='_blank'><button>Ver</button></a></td></tr>";
}

# Cerramos la tabla
print "</table>";

print "<button onclick='history.go(-2)'>Regresar</button>";

print "</div>";

print $cgi->end_html;
