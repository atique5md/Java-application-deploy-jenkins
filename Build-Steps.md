3-tier app java deployment on docker: --
------------------------------------------------------------------------------------------------------------------------------
Expenses-Tracker-WebApp (3 -Tier Application with Docker Compose)

# Java application


Thymeleaf (framework)     #(front end) UI is created on this

Springboot (backend)    #Springboot will be build from a particular tool i.e. maven
        #Maven is a build tool developed by Apache organization 
MySQL (DB)

      (**Apache Maven**)
      [Diagram]

  Thymeleaf    |    Spring boot    |    MySQL DB

    3 container we have to build


We can combine both Thymeleaf & Springboot in an application (frontend + backend)

Base image : Apache Maven

---


  Browser
     |
     v
  Thymeleaf UI
     |
  Spring Boot Application
     |
  MySQL Database

---


🧠 Final Correct Statement 

> Thymeleaf is a server-side template engine that works with Spring Boot. The Spring Boot application is built using Apache Maven and connects to a MySQL database. Thymeleaf and Spring Boot run in the same container, while MySQL runs in a separate container.

---



→ Now start,
Install docker and docker-compse
apt update -y
apt install docker.io -y
# Download Docker Compose v2.37.1 for Linux x86_64
sudo curl -L https://github.com/docker/compose/releases/download/v2.37.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose

# Create symlink to /usr/bin for better compatibility
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installation
docker-compose –version
now clone the repo: --
git clone https://github.com/abhashducat93/Expenses-Tracker-WebApp-3-tier-docker-.git
cd Expenses-Tracker-WebApp-3-tier-docker-/
delete existing dockerfile and docker-compose file: --
rm -v Dockerfile docker-compose.yml

Now, create own Dockerfile

---------------------------
vim Dockerfile


# stage 1 – Build the JAR (Java app runtime) using maven

FROM maven:3.8.3-openjdk-17 AS builder

WORKDIR /app

COPY . .

#Create JAR file #if developer did not create test case or it will be blank, we have to skip them
RUN mvn clean install -DskipTests=true    

# stage 2 – Execute JAR file from above stage

#FROM openjdk:17-alpine   #this no longer exist
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

COPY --from=builder /app/target/*.jar /app/expenseapp.jar

CMD ["java","expenseapp.jar"]

:wq!

---

docker build -t expensesapp .     #expensesapp : name given, -t : flag stands for --tag
docker build --no-cache -t expensesapp .    #if error comes might be take cache so run this

docker images #(it shows that expenses app image will build in 353 mb)

------

vim docker-compose.yml

#version: "3.8"   #not needed in new version

services:

  java_app:
    build:
      context: .
    container_name: "expensesapp"
    networks:
      - expenses-app-nw
    environment:
      SPRING_DATASOURCE_URL: "jdbc:mysql://mysql:3306/expenses_tracker?allowPublicKeyRetrieval=true&useSSL=false"
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: Test@123
      #src;main;resources;application properties you will get environment variables
    depends_on:
      - mysql_db 
    ports:
      - "8080:8080"
    restart: always
    healthcheck:
      test: ["CMD-SHELL","curl -f http://localhost:8080 || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 60s  

    
  mysql_db:
    image: mysql:latest
    container_name: mysql
    networks:
      - expenses-app-nw
    environment:
      MYSQL_ROOT_PASSWORD: Test@123
      MYSQL_DATABASE: expenses_tracker
    restart: always
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD","mysqladmin","ping","-h","localhost","-uroot","-pTest@123"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 60s  
    volumes:
      - ./mysql-data:/var/lib/mysql

networks:
  expenses-app-nw:


:wq!
--------
Now build and run the container 

docker compose up –build    #it will build the app and run container in frontend mode
  OR
       #for run in detach mode

http://localhost:8080

Now, it run successfully

----------------------------------------------------------------------------------------------------------------------------------

now access publicly: --
http://44.221.67.187:8080/
 
Now sign up the account: --
 
 

After signup login the account

 
Now this entry will be verified from database (MySQL)
Connect the MySQL container: --
root@ip-172-31-74-175:/home/ubuntu/Expenses-Tracker-WebApp-3-tier-docker-# docker exec -it 7d9e7d180fbc -u root -p
OCI runtime exec failed: exec failed: unable to start container process: exec: "-u": executable file not found in $PATH: unknown
root@ip-172-31-74-175:/home/ubuntu/Expenses-Tracker-WebApp-3-tier-docker-# docker exec -it 7d9e7d180fbc mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 26
Server version: 9.5.0 MySQL Community Server - GPL

Copyright (c) 2000, 2025, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| expenses_tracker   |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.001 sec)

mysql> use expenses_tracker;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+----------------------------+
| Tables_in_expenses_tracker |
+----------------------------+
| category                   |
| client                     |
| expense                    |
| role                       |
| user                       |
| users_roles                |
+----------------------------+
6 rows in set (0.001 sec)

mysql> select * from user;
Empty set (0.000 sec)

mysql> select * from user;
+----+------------------+--------------------------------------------------------------+-----------+-----------+
| id | enabled          | password                                                     | user_name | client_id |
+----+------------------+--------------------------------------------------------------+-----------+-----------+
|  1 | 0x01             | $2a$10$ojvfGtslFpTZ/ZW9fkkzousZqyjeA3JILriJjYSp9Tk1sXYax7Bym | aman      |         1 |
+----+------------------+--------------------------------------------------------------+-----------+-----------+
1 row in set (0.000 sec)

mysql>





declarative pipeline to deploy above app via Jenkins: --
step1: install docker, Jenkins, git on ubuntu instance
# On the Jenkins agent/node
sudo apt update -y
sudo apt install fontconfig openjdk-21-jre -y
java -version

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install Jenkins -y

sudo apt update -y
sudo apt install docker.io curl git -y
sudo curl -L https://github.com/docker/compose/releases/download/v2.37.1/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Add Jenkins user to docker group (if running as jenkins user)
sudo usermod -aG docker jenkins
# Or for current user
sudo usermod -aG docker $USER

# Verify
docker --version
docker-compose –version

pipeline : -- Direct deployment through Jenkins
pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE_NAME = 'expensesapp'
        REPO_URL = 'https://github.com/abhashducat93/Expenses-Tracker-WebApp-3-tier-docker-.git'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                git url: "${REPO_URL}", branch: 'main'
            }
        }
        
        stage('Explore Repository Structure') {
            steps {
                echo 'Checking repository structure...'
                sh '''
                    echo "=== Current Directory ==="
                    pwd
                    echo "=== Listing all files ==="
                    find . -type f -name "*.java" -o -name "pom.xml" -o -name "*.yml" -o -name "*.yaml" -o -name "Dockerfile" | head -20
                    echo "=== Directory structure ==="
                    ls -la
                    echo "=== Checking for pom.xml ==="
                    find . -name "pom.xml" 2>/dev/null
                '''
            }
        }
        
        stage('Clean Up Existing Files') {
            steps {
                echo 'Removing existing Docker configuration files...'
                sh '''
                    # Find and remove existing Docker configuration files
                    find . -name "Dockerfile" -o -name "docker-compose.yml" -o -name "docker-compose.yaml" | xargs rm -f 2>/dev/null || true
                    
                    echo "=== Files after cleanup ==="
                    ls -la
                '''
            }
        }
        
        stage('Create Dockerfile') {
            steps {
                echo 'Creating Dockerfile...'
                script {
                    // First, let's find where pom.xml is located
                    def pomLocation = sh(script: 'find . -name "pom.xml" -type f | head -1', returnStdout: true).trim()
                    echo "Found pom.xml at: ${pomLocation}"
                    
                    // Create Dockerfile at the root of workspace
                    writeFile file: 'Dockerfile', text: '''# stage 1 – Build the JAR (Java app runtime) using maven

FROM maven:3.8.3-openjdk-17 AS builder

WORKDIR /app

# Copy pom.xml first for better layer caching
COPY pom.xml .
# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests

# stage 2 – Create runtime image
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]'''
                }
            }
        }
        
        stage('Create docker-compose.yml') {
            steps {
                echo 'Creating docker-compose.yml...'
                writeFile file: 'docker-compose.yml', text: '''version: '3.8'

services:
  mysql_db:
    image: mysql:8.0
    container_name: mysql-db
    environment:
      MYSQL_ROOT_PASSWORD: Test@123
      MYSQL_DATABASE: expenses_tracker
      MYSQL_USER: app_user
      MYSQL_PASSWORD: App@123
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-pTest@123"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    restart: unless-stopped

  java_app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: expenses-app
    depends_on:
      mysql_db:
        condition: service_healthy
    environment:
      SPRING_DATASOURCE_URL: jdbc:mysql://mysql-db:3306/expenses_tracker?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
      SPRING_DATASOURCE_USERNAME: root
      SPRING_DATASOURCE_PASSWORD: Test@123
      SPRING_JPA_HIBERNATE_DDL_AUTO: update
      SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT: org.hibernate.dialect.MySQL8Dialect
    ports:
      - "8082:8080"
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    restart: unless-stopped

networks:
  app-network:
    driver: bridge

volumes:
  mysql_data:'''
            }
        }
        
        stage('Verify Files') {
            steps {
                echo 'Verifying created files...'
                sh '''
                    echo "=== Current directory ==="
                    pwd
                    echo "=== Listing files ==="
                    ls -la
                    echo "=== Dockerfile content (first 20 lines) ==="
                    head -20 Dockerfile || echo "Dockerfile not found"
                    echo "=== docker-compose.yml content (first 20 lines) ==="
                    head -20 docker-compose.yml || echo "docker-compose.yml not found"
                    echo "=== Checking for pom.xml ==="
                    find . -name "pom.xml" 2>/dev/null
                    if [ -f "pom.xml" ]; then
                        echo "pom.xml exists in current directory"
                        ls -la pom.xml
                    else
                        echo "Looking for pom.xml in subdirectories..."
                        find . -name "pom.xml" -type f | head -5
                    fi
                '''
            }
        }
        
       stage('Build and Deploy') {
    steps {
        sh '''
            echo "=== Building Docker image ==="
            docker build --no-cache -t expensesapp .

            echo "=== Checking built image ==="
            docker images | grep expensesapp

            echo "=== Stopping old containers ==="
            echo "Stopping previous compose project..."
            docker compose down --remove-orphans || true

            echo "Removing old containers..."
            docker rm -f mysql-db expenses-app 2>/dev/null || true

            echo "Removing old network..."
            docker network rm 3-tier_app-network 2>/dev/null || true

            echo "=== Starting application ==="
            docker compose up -d

            echo "=== Waiting for services ==="
            sleep 10

            echo "=== Container Status ==="
            docker compose ps

            echo "=== Logs ==="
            docker compose logs --tail=20
        '''
    }
}
        
        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployment...'
                script {
                    sleep(30) // Give services time to start
                    
                    sh '''
                        echo "=== Final container status ==="
                        docker compose ps
                        
                        echo "=== Checking application health ==="
                        echo "Waiting for application to be ready..."
                        # Try multiple endpoints
                        for i in {1..10}; do
                            if curl -f http://localhost:8082/actuator/health 2>/dev/null; then
                                echo "Application is healthy!"
                                break
                            elif curl -f http://localhost:8082 2>/dev/null; then
                                echo "Application is responding!"
                                break
                            else
                                echo "Attempt $i: Application not ready yet..."
                                sleep 10
                            fi
                        done
                        
                        echo "=== Application endpoints ==="
                        echo "Java App: http://localhost:8082"
                        echo "MySQL: localhost:3306"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed. Displaying final status...'
            sh '''
                echo "=== Final Docker containers ==="
                docker ps -a
                
                echo "=== Application logs ==="
                docker-compose logs --tail=50 || true
                
                echo "=== Docker images ==="
                docker images | grep -E "(expensesapp|mysql)"
            '''
        }
        success {
            echo 'Deployment completed successfully!'
            echo 'Access the application at: http://localhost:8082'
        }
        failure {
            echo 'Deployment failed!'
            sh '''
                echo "=== Debug information ==="
                echo "Docker version:"
                docker --version
                echo "Docker Compose version:"
                docker compose version
                echo "Current directory:"
                pwd
                echo "Directory contents:"
                ls -la
                echo "Checking for source files:"
                find . -name "*.java" | head -5
                echo "Full error logs:"
                docker compose logs || true
            '''
        }
    }
}


If you want to auto-trigger then do changes on this file---
https://github.com/abhashducat93/Expenses-Tracker-WebApp-3-tier-docker-/blob/main/src/main/resources/templates/landing-page.html
