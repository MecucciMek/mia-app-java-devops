# --- STAGE 1: Build ---
# Usiamo un'immagine con Maven e JDK per compilare il codice
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Copiamo il file pom.xml e scarichiamo le dipendenze (ottimizza la cache di Docker)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copiamo il codice sorgente e creiamo il pacchetto .jar (saltando i test per velocità)
COPY src ./src
RUN mvn clean package -DskipTests

# --- STAGE 2: Run ---
# Usiamo un'immagine JRE (Java Runtime) molto più piccola e sicura per l'esecuzione
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Creiamo un utente non-root per sicurezza (best practice DevOps)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copiamo solo il file JAR generato dallo stage precedente
COPY --from=build /app/target/*.jar app.jar

# Esponiamo la porta classica di Spring Boot
EXPOSE 8080

# Comando per avviare l'applicazione
ENTRYPOINT ["java", "-jar", "app.jar"]