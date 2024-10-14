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
                git branch: 'master', credentialsId: 'jenkins-git', url: 'https://github.com/endrycofr/opengl_c-.git'
            }
        }

        stage('Setup Docker Buildx') {
            steps {
                script {
                    try {
                        sh '''
                              # Create and use a new builder instance
                            docker buildx create --name mybuilder --use || true
                            docker buildx inspect mybuilder --bootstrap
                            

                        '''
                    } catch (Exception e) {
                        error "Failed to setup Docker Buildx: ${e.getMessage()}"
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    try {
                        sh 'make test || echo "make test failed but continuing"'
                    } catch (Exception e) {
                        echo "Warning: make test failed. Error: ${e.getMessage()}"
                    }

                    try {
                        sh 'cppcheck --enable=all --inconclusive --xml --xml-version=2 . 2> cppcheck-result.xml || echo "cppcheck failed but continuing"'
                        publishCppcheck pattern: 'cppcheck-result.xml'
                    } catch (Exception e) {
                        echo "Warning: cppcheck failed. Error: ${e.getMessage()}"
                    }
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'b4ac2fbd-6690-4234-a6de-cdeba8ccb7b8', toolName: 'Docker') {
                        try {
                            sh """
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
                                    docker run -d --name opengl-app \\
                                        -e DISPLAY=:0 \\
                                        --device /dev/dri \\
                                        -v /tmp/.X11-unix:/tmp/.X11-unix \\
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
            sh 'docker buildx rm multiarch-builder || true'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed. Please check the logs for details.'
        }
    }
}