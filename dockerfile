# ===== Stage 1: Build (Gradle) =====
FROM gradle:8.7-jdk17 AS builder
WORKDIR /workspace

# 캐시 최적화: 의존성/설정 먼저 복사
COPY gradle gradle
COPY gradlew build.gradle settings.gradle ./
# 멀티모듈이면 필요한 파일도 추가
# COPY build.gradle.kts settings.gradle.kts ./

# 소스 복사
COPY src src

# 빌드 (테스트 제외는 필요 시 주석 해제)
RUN ./gradlew build -x test -x checkstyleMain -x checkstyleTest

# ===== Stage 2: Run (JRE only) =====
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# 빌드 산출물 복사 (bootJar 결과가 1개라고 가정)
COPY --from=builder /workspace/build/libs/*.jar /app/app.jar

# 실행 옵션(필요시)
ENV JAVA_OPTS=""

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]

