#!/usr/bin/perl
use CGI qw(:standard);
use strict;
use warnings;
use utf8;  # Asegura que el código fuente esté en UTF-8
binmode(STDOUT, ":utf8");

# Imprimir encabezados HTTP y redirigir a la página de inicio
print header();
print start_html(
    -title => "Cerrar sesión",
    -style => { -code => q{
        body {
            background: linear-gradient(to bottom, #E0FFFF, #008080); /* Degradado de celeste a verde agua */
            color: #FFFFFF; /* Texto blanco */
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            height: 100vh; /* Altura total de la ventana */
            margin: 0; /* Eliminar márgenes */
        }
        h1 {
            color: #FFFFFF; /* Encabezado en blanco */
            text-shadow: 2px 2px 4px #004D40; /* Sombra para destacar */
        }
        a {
            color: #004D40; /* Verde oscuro */
            text-decoration: none;
            font-weight: bold;
        }
        a:hover {
            color: #00796B; /* Verde agua más claro */
        }
    } }
);

print "<h1>Sesion cerrada exitosamente</h1>";
print "<p>Haz clic <a href='../index.html'>aqui</a> para volver a la pagina principal.</p>";
print end_html;
