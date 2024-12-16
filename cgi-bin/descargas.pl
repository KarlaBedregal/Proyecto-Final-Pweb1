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

print <<EOF;
<!DOCTYPE html>
<html lang="es">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tabla de descargas</title>
    <style>
        body {
        font-family: Arial, sans-serif;
        background-color: #ffffff;
        margin: 0 20px;
        padding: 0;
        display: flex;
        align-items: center;
        height: 100vh; 
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
        margin: 0; /* Alinear el formulario al borde izquierdo */
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
    }

    /* Estilos para las tablas */
    table {
        width: 100%;
        border-collapse: collapse; /* Hace que las celdas estén unidas */
        margin-top: 20px;
    }

    th, td {
        padding: 10px;
        text-align: center; /* Centra el contenido de las celdas */
        border: 1px solid #ddd;
    }

    th {
        background-color: #4facfe;
        color: white;
    }

    tr:nth-child(even) {
        background-color: #f2f2f2; /* Agrega un color de fondo alternativo para filas pares */
    }

    /* Estilos para el modal de edición */
    #modalEdit {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, 0.5); /* Fondo semitransparente */
        justify-content: center;
        align-items: center;
        z-index: 9999;
    }

    #modalEdit div {
        background-color: #fff;
        padding: 20px;
        width: 300px;
        border-radius: 10px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }

    button {
        margin: 5px;
    }

    /* Estilos de los botones al final */
    button {
        padding: 10px 20px;
        background-color: #6dd436;
        border: none;
        border-radius: 8px;
        color: white;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }

    button:hover {
        background-color: #4caf50; /* Cambio de color al pasar el mouse */
    }

    </style>
    </head>

<body>
<div class="contenedor-flex">
EOF

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
        print "<button href='#' onclick='editarCancion(" . $row->{id} . ", \"" . $row->{nombre_cancion} . "\")'>Editar</button> | ";
        print "<button href='#' onclick='eliminarCancion(" . $row->{id} . ")'>Eliminar</button> |";
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
<div>
    <button onclick="history.back()">Volver</button> <br><br>
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


