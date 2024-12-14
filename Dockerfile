# Usar la imagen base Debian
FROM debian:latest

# Instalar MariaDB, Apache, Perl y módulos requeridos
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    apache2 \
    libapache2-mod-perl2 \
    perl \
    wget \
    curl \
    libdbi-perl \
    libdbd-mysql-perl \
    libdigest-sha-perl \
    && apt-get clean

# Configurar el entorno
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=mi_base_de_datos
ENV MYSQL_USER=mi_usuario
ENV MYSQL_PASSWORD=mi_contrasena

# Crear el directorio /var/www/html/cgi-bin si no existe
RUN mkdir -p /var/www/html/cgi-bin

# Copiar los scripts Perl y otros archivos al contenedor
COPY ./cgi-bin/*.pl /var/www/html/cgi-bin/
COPY ./html/*.html /var/www/html/
COPY ./html/styles.css /var/www/html/
COPY ./html/formularios.css /var/www/html/ 
COPY ./images/iconodownloaderbyte.png /var/www/html/images/
COPY ./init.sql /tmp/init.sql

# Establecer permisos adecuados para los scripts CGI
RUN chmod +x /var/www/html/cgi-bin/*.pl && \

    chown -R www-data:www-data /var/www/html/cgi-bin/ && \
    chown -R www-data:www-data /var/www/html/

# Agrega la configuración CGI a Apache
RUN echo 'ScriptAlias /cgi-bin/ /var/www/html/cgi-bin/' >> /etc/apache2/sites-available/000-default.conf && \
    echo '<Directory "/var/www/html/cgi-bin">' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    AllowOverride None' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    Options +ExecCGI' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    Require all granted' >> /etc/apache2/sites-available/000-default.conf && \
    echo '    AddHandler cgi-script .pl' >> /etc/apache2/sites-available/000-default.conf && \
    echo '</Directory>' >> /etc/apache2/sites-available/000-default.conf

# Habilitar CGI en Apache
RUN a2enmod cgi && \
    sed -i 's|/usr/lib/cgi-bin|/var/www/html/cgi-bin|' /etc/apache2/conf-available/serve-cgi-bin.conf && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN service mariadb start && \
    mysql -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;" -u root && \
    mysql -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" -u root && \
    mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%'; FLUSH PRIVILEGES;" -u root && \
    mysql -u root $MYSQL_DATABASE < /tmp/init.sql

# Exponer los puertos
EXPOSE 80 3306

# Comando para iniciar los servicios
CMD ["sh", "-c", "service mariadb start && apache2ctl -D FOREGROUND"]