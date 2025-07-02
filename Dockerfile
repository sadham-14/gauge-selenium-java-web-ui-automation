# ---------- Stage 1: Build with Maven ----------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

RUN apt-get update && apt-get install -y curl unzip \
    && curl -Lo /tmp/gauge.zip https://github.com/getgauge/gauge/releases/download/v1.6.18/gauge-1.6.18-linux.x86_64.zip \
    && unzip /tmp/gauge.zip -d /usr/local/gauge \
    && ln -s /usr/local/gauge/gauge /usr/local/bin/gauge \
    && gauge --version

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY . .
RUN mvn clean install -DskipTests

# ---------- Stage 2: Run Gauge tests ----------
FROM eclipse-temurin:17-jdk

RUN apt-get update && apt-get install -y curl unzip \
    && curl -Lo /tmp/gauge.zip https://github.com/getgauge/gauge/releases/download/v1.6.18/gauge-1.6.18-linux.x86_64.zip \
    && unzip /tmp/gauge.zip -d /usr/local/gauge \
    && ln -s /usr/local/gauge/gauge /usr/local/bin/gauge \
    && gauge --version

WORKDIR /app
COPY --from=builder /app /app

CMD ["gauge", "run", "specs"]
