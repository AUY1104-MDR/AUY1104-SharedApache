FROM httpd:2.4-alpine

# Configuramos Apache para que escuche internamente en el puerto 30100
RUN sed -i 's/Listen 80/Listen 30100/g' /usr/local/apache2/conf/httpd.conf

# Copiamos tu sitio personalizado
COPY index.html /usr/local/apache2/htdocs/

EXPOSE 30100