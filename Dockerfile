# -------- Stage 1: Build the Java Project with Maven --------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /app

# Copy only pom.xml to cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy full project and build
COPY . .
RUN mvn clean package -DskipTests

# -------- Stage 2: Run the Project --------
FROM eclipse-temurin:17-jdk

# Create app directory
WORKDIR /app

# Copy built jar from previous stage
COPY --from=builder /app/target/*.jar app.jar

# Optional: expose port if your app listens to one
EXPOSE 8080

# Default command to run your app
ENTRYPOINT ["java", "-jar", "app.jar"]
