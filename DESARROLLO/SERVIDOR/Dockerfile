# Etapa 1: Construir el JAR
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
# Copia el archivo pom.xml y descarga las dependencias
COPY pom.xml .
RUN apk add --no-cache maven && mvn dependency:go-offline
# Copia el código fuente y construye el JAR
COPY src ./src
RUN mvn clean package -DskipTests

# Etapa 2: Crear la imagen final
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# Copia el JAR desde la etapa de construcción
COPY --from=builder /app/target/web-0.0.1-SNAPSHOT.jar app.jar
# Expón el puerto dinámico
EXPOSE ${PORT}
# Ejecuta la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]