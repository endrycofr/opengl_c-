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

        stage('Build and Test') {
            steps {
                sh 'make'
                sh 'make test'
                sh 'cppcheck --enable=all --inconclusive --xml --xml-version=2 . 2> cppcheck-result.xml'
                publishCppcheck pattern: 'cppcheck-result.xml'
            }
        }

        stage('Setup Docker Buildx') {
            steps {
                sh '''
                    docker buildx create --use --name multiarch-builder
                    docker buildx inspect --bootstrap
                '''
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'b4ac2fbd-6690-4234-a6de-cdeba8ccb7b8', toolName: 'Docker') {
                        sh """
                            docker buildx build --push \
                                --platform linux/amd64,linux/arm64 \
                                -t ${DOCKER_IMAGE}:${DOCKER_TAG} \
                                -t ${DOCKER_IMAGE}:latest .
                        """
                    }
                }
            }
        }

        stage('Deploy to Raspberry Pi') {
            steps {
                sshagent(['raspi-ssh-key']) {
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
                }
            }
        }
    }

    post {
        always {
            cleanWs()
            sh 'docker buildx rm multiarch-builder'
        }
    }
}