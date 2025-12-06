# 1. Elegimos una base oficial de Python (ligera pero compatible)
# Usamos 'slim' que está basada en Debian (compatible con Bookworm)
FROM python:3.11-slim

# Metadatos (Buenas prácticas)
LABEL maintainer="GRUPO-JI-08"
LABEL description="Imagen para gestionar con Ansible una infraestructura CISCO"

# 2: Variables de Entorno (recomendadas en las guías)
# Evita que Python genere archivos compilados .pyc (basura) que se borrarán luego (no tenemos mucho espacio)
ENV PYTHONDONTWRITEBYTECODE=1
# Evita que Python bufferice la salida y acumule logs en RAM antes de sacarlos por pantalla (para ver logs en tiempo real)
# Si es contenedor crashea y no está puesto, te quedas sin ver esto último (aún estaría en RAM sin haber salido por pantalla)
ENV PYTHONUNBUFFERED=1

# Ahora vienen los RUN instalando "capas de cebolla" con nuevas funcionalidades. Es importante que cada capa de cebolla ocupe lo menos posible

# Instalación de Paquetes del Sistema (La capa "apt")
# Aquí solucionamos lo que nos faltaba en Alpine:
# - sshpass: nos va a hacer falta para poder escribir las contraseñas de acceso a router/switch al ejecutar Ansible y no dejarla escrita en ficheros de tex
# - nano: por si tenemos que editar algún fichero dentro del contenedor
# - git: Para bajar colecciones de Galaxy (para conectarnos a GitHub y bajar código que ha escrito otra gente y lo ha dejado ahí a disposición de la comunidad)
# - iputils-ping: Para hacer troubleshooting básico desde el contenedor (ping, etc.)
# - gcc, linc6-dev son compiladores necesarios para librerías de Ansible que isntalaré luego (ansible-pylibssh)
# ----- instala solo las dependencias OBLIGATORIAS de cada paquete: no las RECOMENDADAS, ni, por supuesto, las SUGERIDAS (para no acumular cosas innecesarias)
# ------------ "Por favor, la hamburguesa sola. Sin patatas, sin bebida y sin el juguete de regalo. Estoy a dieta (de espacio)."
# ----- al final borramos el catálogo de "novedades" descargado con update, porque ya hemos hecho el "pedido"; nos ocuparía espacio (quiza 100MB) ...
# ------------ Después de mirar el catálogo de IKEA y comprar el mueble, tiro el catálogo a la basura antes de salir. No me lo llevo a casa porque pesa y ya tengo el mueble.
# ------------ lo hacemos con && en la misma línea, para que esa "capa de cebolla" se deshaga de esos 100MB del update
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    libssh-dev \
    sshpass \
    openssh-client \
    git \
    nano \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# 4: Instalación de Ansible y Librerías Python
# Instalamos Ansible
# Isntalamos la librería moderna ansible-pylibssh (escrita en C)
# Instalamos también 'paramiko' (quizá necesario para ejecutar comandos en algunos equipos Cisco antiguos/SB) o por si falla la buena
# ------ el no caché indica que no se quede con el archivo comprimido del paquete (tar, zip) (lo típico que hacemos para instalar: bajamos un zip, descomprimimos e instalam)
# ------ tiramos el .zip a la basura, porque ya no lo necesitamos (no lo vamos a volver a instalar de nuevo nunca aquí)
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    ansible \
    ansible-pylibssh \
    paramiko

# 5: Instalación de Colecciones de Red
# ------ Ya tenemos Ansible Core, pero ahora faltan utilidades específicas para los dispositivos en los que lo vamos a usar::
# ------ Ten en cuenta que nosotros vamos a usarlo para CISCO, pero hay para TODO: automatizar un Windows, un Linux, un TP-Link, un Firewall ....
# ----------Cisco IOS (para el 1941/1841), 
# ----------community.network para el Switch 300 series: (community.network incluye los módulos legacy community.network.sbox, 
#           que son los que se usaban antiguamente para esos equipos)
# ----------y el resto como dependencias generales
RUN ansible-galaxy collection install \
    ansible.netcommon \
    community.network \
    cisco.ios \
    community.general

# Limpieza final (Opcional pero recomendada para reducir tamaño)
# Borramos cachés de compilación que ya no sirven
RUN rm -rf /root/.cache

# 7: Configuración del entorno de trabajo
# Creamos la carpeta donde montaremos nuestros ficheros (es en la que "apareceremos al conectarnos)
WORKDIR /ansible

# Comando por defecto al arrancar el contenedor: una shell bash
CMD ["/bin/bash"]
