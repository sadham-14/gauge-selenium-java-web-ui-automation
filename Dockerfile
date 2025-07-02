# -------- Stage 1: Build the project --------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Install unzip and gauge CLI
RUN apt-get update && apt-get install -y curl unzip \
    && curl -SsL https://downloads.gauge.org/stable | sh \
    && mv ~/.gauge/bin/gauge /usr/local/bin/gauge \
    && gauge --version

WORKDIR /app

# Copy pom and preload dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy rest of the source code
COPY . .

# Build the project
RUN mvn clean package -DskipTests

# -------- Stage 2: Run gauge specs --------
FROM eclipse-temurin:17-jdk

# Install unzip and gauge CLI
RUN apt-get update && apt-get install -y curl unzip \
    && curl -SsL https://downloads.gauge.org/stable | sh \
    && mv ~/.gauge/bin/gauge /usr/local/bin/gauge \
    && gauge --version

WORKDIR /app

# Copy everything from builder
COPY --from=builder /app /app

# Default command: run gauge specs
CMD ["gauge", "run", "specs"]
