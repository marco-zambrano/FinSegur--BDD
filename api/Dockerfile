# finsegur-project/api/Dockerfile

# Usar una imagen oficial de Node.js como base. Alpine es una versión ligera.
FROM node:18-alpine

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /usr/src/app

# Copiar package.json y package-lock.json (si existe)
# Esto aprovecha el caché de Docker. El paso de 'npm install' solo se ejecutará si estos archivos cambian.
COPY package*.json ./

# Instalar las dependencias de la aplicación
RUN npm install

# Copiar el resto del código fuente de la aplicación al directorio de trabajo
COPY . .

# La API estará disponible en el puerto 3000 dentro del contenedor
EXPOSE 3000

# Definir el comando para ejecutar la aplicación cuando se inicie el contenedor
CMD [ "npm", "start" ]