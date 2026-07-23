# stage 1 – Build the JAR (Java app runtime) using maven
FROM maven:3.8.3-openjdk-17 AS builder

WORKDIR /app

COPY . .

#create JAR file
RUN mvn clean package -DskipTests=true		



# stage 2 – Execute JAR file from above stage

#FROM openjdk:17-alpine 	#this no longer exist
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=builder /app/target/*.jar /app/expenseapp.jar

CMD ["java","-jar","expenseapp.jar"]
