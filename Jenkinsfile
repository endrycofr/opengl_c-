pipeline {
    agent any
 
    tools {
    conan 'conan'
    }

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

stage('Install C++ Dependencies with Conan') {
    steps {
        script {
            // Install Conan if it's not already installed
            sh '''
                if ! command -v conan &> /dev/null; then
                    pip install conan --user
                    export PATH=$PATH:$HOME/.local/bin
                fi
                conan install . --build=missing
                mkdir build
                cd build
                make ..
            '''
        }
    }
}


        stage('Build with Make') {
            steps {
                sh 'make -C build'
            }
        }

        stage('Test') {
            steps {
                sh 'make -C build test'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    try {
                        sh """
                            docker info
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
