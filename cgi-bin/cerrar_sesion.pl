#!/usr/bin/perl
use CGI qw(:standard);
use strict;
use warnings;
use utf8;  # Asegura que el código fuente esté en UTF-8
binmode(STDOUT, ":utf8");

# Imprimir encabezados HTTP y redirigir a la página de inicio
print header();
print start_html("Cerrar sesión");
print "<h1>Sesión cerrada exitosamente</h1>";
print "<p>Has cerrado tu sesión. Haz clic <a href='../html/index.html'>aquí</a> para volver a la página principal.</p>";
print end_html;

