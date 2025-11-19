# ========= BUILD STAGE =========
FROM maven:3.9-eclipse-temurin-21-alpine AS build

WORKDIR /app

COPY pom.xml .

COPY src ./src

RUN mvn -q -DskipTests package

# ========= RUNTIME STAGE =========
FROM amazoncorretto:21-alpine

WORKDIR /app

COPY --from=build /app/target/sentiment-docker-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
