# Minikube CI/CD 

A complete ci/cd pipeline for basic NodeJS app.

* Stack: Git -> Jenkins -> Sonarqube (report to postgresql) -> Docker Build/Push -> Kubernetes (deployment) 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What things you need to pre-install:
* Docker
* Docker-compose

### Installing

A step by step guide that will tell you how to get a development env running:

1. Build custom jenkins image with docker, nodejs and kubectl
```
docker build -t jenkins/Dockerfile -t {custom_name} .
```
2. Bring up the Jenkins, Sonarqube and Postgresql. (local machine)
```
docker-compose up -d

* Note: Run "systemctl -w vm.max_map_count = 262144" as it is required by sonarqube
        Don't forget to change jenkins container image field value with {custom_name} in docker-compose.yaml 
```
3. Download the require plugins for jenkins (other than suggested ones):

* [SonarQube Scanner](https://plugins.jenkins.io/sonar/)
* [Kubernetes CLI](https://plugins.jenkins.io/kubernetes-cli/)
* [CloudBees Docker Build and Publish](https://plugins.jenkins.io/docker-build-publish/)
* [Docker Pipeline](https://plugins.jenkins.io/docker-workflow/)
* [NodeJS](https://plugins.jenkins.io/nodejs/)

4. Spin up a local kubernetes cluster (minikube)
```
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start

* Note: verify k8s server ip is reachable from jenkins pod if not, add minikube container to same network and make a entry in /etc/hosts with name as kubernetes
* Eg: docker network connect honest-food-task_jenkins minikube
      {ip} kubernetes // in /etc/hosts inside docker as x509 cert is not valid for hostname minikube
```

5. Store the required credentials in jenkins credential store: (http://{ip}:8080)

* Github (Username with password): Your personal credentials
* Docker Hub (Username with password): Your personal credentials
* Kubernetes (Secret file): Respective kube.config file with Certificate Authority data (if file, verify path is correct)
* Sonarqube  (Secret text): Login token generate on sonar server (http://{ip}:9000)

6. Create a job in jenkins:
```
New Item -> Pipeline -> Pipeline from scm ->  SCM: git -> ADD Repository URL + Credentials -> Save -> Build Now

Note: User this repo url: "https://github.com/rijulrg/minikube-ci-cd.git" for testing pupose as it contains a basic nodejs app as well.

** Pipeline File: ./Jenkinsfile
** Dockerfile for NodeJS app: ./Dockerfile
** Files related to  NodeJS app: ./test-app
```
