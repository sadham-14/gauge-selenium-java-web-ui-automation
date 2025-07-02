# -------- Stage 1: Build with Maven + Gauge CLI --------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Install Gauge CLI
RUN curl -SsL https://downloads.gauge.org/stable | sh \
    && mv ~/.gauge/bin/gauge /usr/local/bin/gauge \
    && gauge --version

# Set working directory
WORKDIR /app

# Copy only pom.xml to cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy entire project
COPY . .

# Build with gauge CLI required
RUN mvn clean package -DskipTests

# -------- Stage 2: Just for running tests manually if needed --------
FROM eclipse-temurin:17-jdk

# Install Gauge CLI
RUN apt-get update && apt-get install -y curl \
    && curl -SsL https://downloads.gauge.org/stable | sh \
    && mv ~/.gauge/bin/gauge /usr/local/bin/gauge \
    && gauge --version

# Create app folder
WORKDIR /app

# Copy project from builder
COPY --from=builder /app /app

# Default command (you can override in `docker run`)
CMD ["gauge", "run", "specs"]
