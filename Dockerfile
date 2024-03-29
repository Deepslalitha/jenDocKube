# Use Jenkins base image
FROM jenkins/jenkins:latest

# Install necessary dependencies
USER root

# Install prerequisites
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io

# Add jenkins user to docker group
RUN usermod -aG docker jenkins

# Install sudo
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*

# Add jenkins user to sudoers
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# Update and upgrade system
RUN apt-get update -y && \
    apt-get upgrade -y

# Install wget
RUN apt-get install -y wget

# Java 17 installation step
RUN apt install openjdk-17-jdk openjdk-17-jre -y && \
    java --version

# Maven install step
RUN apt install maven -y && \
    mvn -version

# Install Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    chmod +x kubectl && \
    mkdir -p ~/.local/bin && \
    mv ./kubectl ~/.local/bin/kubectl && \
    kubectl version --client



# Setting the number of executors
COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
COPY maven-global-settings-files.xml /usr/share/jenkins/ref/maven-global-settings-files.xml
