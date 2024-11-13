pipeline {
    agent any
    stages {
        stage('Git Checkout') {
            steps {
                git changelog: false, poll: false, url: 'https://github.com/endrycofr/opengl_c-.git'
            }
        }

        stage('Docker setup') {
            steps {
                script {
                    
                        sh 'sudo usermod -aG docker jenkins'
                        sh 'sudo chown -R jenkins:docker /var/run/docker.sock'
                        sh 'make buildx-setup'
                    
                }
            }
        }
        stage('Docker Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: '55f6f145-13b5-4d9c-8ea4-a0f515a2212c', toolName: 'docker') {
                   
                        sh 'make buildx-push'
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded! Images built and pushed successfully.'
        }
        failure {
            echo 'Pipeline failed! Check the logs for details.'
        }
    }
}