#!/usr/bin/perl
use strict;
use warnings;
use CGI qw(:standard);
use DBI;
use utf8;
binmode(STDOUT, ":utf8");

my $cgi = CGI->new;

# Configuración de conexión a la base de datos
my $dsn = "DBI:mysql:database=mi_base_de_datos;host=localhost";
my $usuario = "mi_usuario";
my $contraseña = "mi_contraseña";
my $dbh = DBI->connect($dsn, $usuario, $contraseña) or die "No se pudo conectar a la base de datos: $DBI::errstr";

# Obtener la acción (editar, eliminar) y el ID de la canción a editar/eliminar
my $accion = $cgi->param('action') || '';
my $id_cancion = $cgi->param('id_cancion') || '';

# Si se recibe una acción de eliminar
if ($accion eq 'eliminar' && $id_cancion) {
    my $sth = $dbh->prepare("DELETE FROM canciones WHERE id = ?");
    $sth->execute($id_cancion);
    print $cgi->header('text/html; charset=UTF-8');
    print "<h3>Canción eliminada con éxito.</h3>";
}

# Consultar la base de datos
my $query_directorio = "SELECT DISTINCT directorio FROM canciones";
my $sth_directorio = $dbh->prepare($query_directorio);
$sth_directorio->execute();

print $cgi->header('text/html; charset=UTF-8');
print $cgi->start_html('Tabla de Canciones');

while (my $dir_row = $sth_directorio->fetchrow_hashref) {
    my $directorio = $dir_row->{directorio};
    print "<h2>Lista: $directorio</h2>";

    # Consultar las canciones de ese directorio
    my $query_canciones = "SELECT * FROM canciones WHERE directorio = ?";
    my $sth_canciones = $dbh->prepare($query_canciones);
    $sth_canciones->execute($directorio);

    print "<table border='1'>";
    print "<tr><th>ID</th><th>Nombre Canción</th><th>URL</th><th>Directorio</th><th>Fecha Descarga</th><th>Acciones</th></tr>";

    while (my $row = $sth_canciones->fetchrow_hashref) {
        print "<tr>";
        print "<td>" . $row->{id} . "</td>";
        print "<td>" . $row->{nombre_cancion} . "</td>";
        print "<td>" . $row->{url} . "</td>";
        print "<td>" . $row->{formato} . "</td>";
        print "<td>" . $row->{fecha_descarga} . "</td>";

        # Enlaces para editar y eliminar con AJAX
        print "<td>";
        print "<a href='#' onclick='editarCancion(" . $row->{id} . ", \"" . $row->{nombre_cancion} . "\")'>Editar</a> | ";
        print "<a href='#' onclick='eliminarCancion(" . $row->{id} . ")'>Eliminar</a> |";
        print "</td>";
    }

    print "</table>";
}

# Agregar el modal de edición
print <<'HTML';
<!-- Modal para editar -->
<div id="modalEdit" style="display:none;">
    <div style="background-color:#fff; padding:20px; width:300px; margin:auto; border:1px solid #ccc; box-shadow:0 4px 8px rgba(0, 0, 0, 0.1);">
        <h3>Editar Canción</h3>
        <form id="editForm">
            <input type="hidden" id="editId">
            <label for="nombre_cancion">Nuevo nombre: </label>
            <input type="text" id="editNombre" required>
            <br><br>
            <button type="button" onclick="submitEdit()">Actualizar</button>
            <button type="button" onclick="cerrarModal()">Cerrar</button>
        </form>
    </div>
</div>


<!-- Botones adicionales -->
<div style="margin-top:20px;">
    <button onclick="history.back()">Volver</button>
    <form action="config.pl" method="get">
        <button type="submit">Cambiar las propiedades de mis descargas</button>
    </form>
</div>

<script>
    function editarCancion(id, nombre) {
        // Mostrar el modal y establecer el valor del campo
        document.getElementById('editId').value = id;
        document.getElementById('editNombre').value = nombre;
        document.getElementById('modalEdit').style.display = 'block';
    }

    function cerrarModal() {
        // Ocultar el modal
        document.getElementById('modalEdit').style.display = 'none';
    }

    function submitEdit() {
        var id = document.getElementById('editId').value;
        var nombre = document.getElementById('editNombre').value;

        // Realizar la solicitud AJAX para editar la canción
        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'update_song.pl', true);  // Apuntar a un script Perl de actualización
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function () {
            if (xhr.readyState == 4 && xhr.status == 200) {
                alert('Canción actualizada');
                cerrarModal();
                location.reload();  // Recargar la página para reflejar el cambio
            }
        };
        xhr.send('action=editar&id_cancion=' + id + '&nombre_cancion=' + encodeURIComponent(nombre));
    }

    function eliminarCancion(id) {
        if (confirm('¿Estás seguro de que quieres eliminar esta canción?')) {
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'delete_song.pl', true);  // Apuntar a un script Perl de eliminación
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onreadystatechange = function () {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    alert('Canción eliminada');
                    location.reload();  // Recargar la página para reflejar la eliminación
                }
            };
            xhr.send('action=eliminar&id_cancion=' + id);
        }
    }
    
</script>
HTML

print $cgi->end_html;


