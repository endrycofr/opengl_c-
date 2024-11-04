pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS = '835d1510-5e15-4dbb-b585-9185fdda5149'
        DOCKER_REGISTRY = 'https://hub.docker.com/repository/docker/endrycofr'
        DOCKER_IMAGE = 'endrycofr/cpp_opengl'
        DOCKER_TAG = "${BUILD_NUMBER}"
        RASPI_USER = 'pi'
        RASPI_HOST = 'raspberrypi.local'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'master', credentialsId: '0ddd4d71-03a1-42a9-ae6e-d48f6d93d3d2', url: 'https://github.com/endrycofr/opengl_c-'
            }
        }
          stage('Test') {
            steps {
                sh 'make test'
            }
        }

        stage('Docker build') {
            steps {
                sh 'make image'
            }
       }
         stage('Docker push') {
            scripts {
                sh 'make push'
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
