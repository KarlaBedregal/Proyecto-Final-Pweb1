#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $cgi = CGI->new;
my $dbh = DBI->connect("DBI:mysql:database=mi_base_de_datos;host=localhost", "mi_usuario", "mi_contraseña") or die "No se pudo conectar a la base de datos: $DBI::errstr";

my $id_cancion = $cgi->param('id_cancion');

if ($id_cancion) {
    my $sth = $dbh->prepare("DELETE FROM canciones WHERE id = ?");
    $sth->execute($id_cancion);
}

print $cgi->header('text/html; charset=UTF-8');
print "Canción eliminada con éxito.";

