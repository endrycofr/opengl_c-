pipeline {
    agent any

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/akarsh/selenium-webdriver-cucumber-js-example-project.git'

            }
        }

        stage('Build') {
            steps {
                sh 'make'
                archiveArtifacts artifacts: 'myapp', fingerprint: true
            }
        }

        stage('Test') {
            steps {
                sh 'make test'
                sh 'cppcheck --enable=all --inconclusive --xml --xml-version=2 . 2> cppcheck-result.xml'
                publishCppcheck pattern: 'cppcheck-result.xml'
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['raspi-ssh-key']) {
                    sh '''
                        scp myapp pi@raspberrypi:/home/pi/myapp
                        ssh pi@raspberrypi "sudo systemctl restart myapp.service"
                    '''
                }
            }
        }
    }
}