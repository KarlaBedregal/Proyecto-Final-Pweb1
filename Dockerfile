# Usar una imagen base de Debian con Apache y Perl preinstalados
FROM debian:latest

# Instala Apache, Perl, MariaDB y dependencias necesarias
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-perl2 \
    mariadb-server \
    mariadb-client \
    perl \
    libdbi-perl \
    libdbd-mysql-perl \
    libcgi-pm-perl \
    libdigest-sha-perl \
    curl && \
    apt-get clean

# Crear el directorio /var/www/html/cgi-bin si no existe
RUN mkdir -p /var/www/html/cgi-bin

# Copia tu script Perl y otros archivos al contenedor
COPY ./cgi-bin/*.pl /var/www/html/cgi-bin/
COPY ./html/index.html /var/www/html/
COPY ./html/styles.css /var/www/html/
COPY ./images/*.png /var/www/html/

# Establecer permisos adecuados para los scripts CGI
RUN chmod +x /var/www/html/cgi-bin/*.pl && \
    chown -R www-data:www-data /var/www/html/cgi-bin/ && \
    chown -R www-data:www-data /var/www/html/

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Deshabilitar MPM event y worker antes de habilitar mpm_prefork
RUN a2enmod cgi
    
# Configurar Apache para usar /var/www/html/cgi-bin como directorio CGI
RUN sed -i 's|/usr/lib/cgi-bin|/var/www/html/cgi-bin|' /etc/apache2/conf-available/serve-cgi-bin.conf

# Modificar la configuración de Apache para habilitar CGI y establecer el archivo index
RUN echo '<Directory /var/www/html>' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    Options +ExecCGI' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    AddHandler cgi-script .pl' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    DirectoryIndex index.html' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</Directory>' >> /etc/apache2/sites-available/000-default.conf

# Configurar MariaDB para aceptar conexiones y crear el usuario para la base de datos
COPY init_db.sql /docker-entrypoint-initdb.d/

# Exponer el puerto 80 para Apache
EXPOSE 80

# Punto de entrada: iniciar MariaDB y Apache
CMD service mariadb start && apachectl -D FOREGROUND

