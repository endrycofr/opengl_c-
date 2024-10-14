pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'endrycofr/cpp_opengl'
        DOCKER_TAG = "${BUILD_NUMBER}"
        RASPI_USER = 'pi'
        RASPI_HOST = 'raspberrypi.local'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git credentialsId: 'jenkins-git', url: 'https://github.com/endrycofr/opengl_c-.git'
            }
        }
        stage('Install and Configure Docker') {
    steps {
        sh 'sudo apt-get update && sudo apt-get install -y docker.io'
        sh 'sudo systemctl start docker'
        sh 'sudo usermod -aG docker jenkins'
    }
}


        stage('Build and Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'Dockerhub', toolName: 'Docker') {
                        try {
                            sh """
                            docker version
                            docker buildx version
                            docker buildx create --name mybuilder --use || true
                            docker buildx inspect mybuilder --bootstrap
                            docker buildx build --push \
                                --platform linux/amd64,linux/arm64 \
                                -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                                -t ${DOCKER_IMAGE}:latest .
                            """
                        } catch (Exception e) {
                            error "Failed to build or push Docker image: ${e.getMessage()}"
                        }
                    }
                }
            }
        }

        stage('Deploy to Raspberry Pi') {
            steps {
                script {
                    sshagent(['raspi-ssh-key']) {
                        try {
                            sh """
                                ssh -o StrictHostKeyChecking=no ${RASPI_USER}@${RASPI_HOST} '
                                    export DISPLAY=:0
                                    xhost +
                                    docker pull ${DOCKER_IMAGE}:${DOCKER_TAG}
                                    docker stop opengl-app || true
                                    docker rm opengl-app || true
                                    docker run -d --name opengl-app \
                                        -e DISPLAY=:0 \
                                        --device /dev/dri \
                                        -v /tmp/.X11-unix:/tmp/.X11-unix \
                                        ${DOCKER_IMAGE}:${DOCKER_TAG}
                                '
                            """
                        } catch (Exception e) {
                            error "Failed to deploy to Raspberry Pi: ${e.getMessage()}"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
            sh 'docker buildx rm mybuilder || true'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for details.'
        }
    }
}