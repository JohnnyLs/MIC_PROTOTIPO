# Etapa de construccion - Optimizada para cache de dependencias
FROM eclipse-temurin:17-jdk-jammy AS builder

# Instala Maven primero
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*


WORKDIR /app
# Copia solo el POM primero para cachear dependencias
COPY pom.xml .
# Descarga dependencias (capa cacheable)
RUN mvn dependency:go-offline -B

# Copia todo el código fuente
COPY src ./src
# Empaqueta la aplicacion preservando tu application.properties
RUN mvn clean package -DskipTests

# Etapa de ejecucion - Minimalista y segura
FROM eclipse-temurin:17-jre-jammy

WORKDIR /app
# Copia el JAR manteniendo tu configuracion embebida
COPY --from=builder /app/target/*.jar app.jar

# Puerto expuesto (coincide con tu server.port=8082)
EXPOSE 8082

# Entrypoint seguro sin exponer variables sensibles
ENTRYPOINT ["java", "-jar", "app.jar"]