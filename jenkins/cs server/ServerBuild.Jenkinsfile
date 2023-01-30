pipeline {
    agent {
        docker {
            image '352708296901.dkr.ecr.eu-central-1.amazonaws.com/yf-bot-reg:latest'
            args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    options {
    buildDiscarder(logRotator(daysToKeepStr: '5'))
    disableConcurrentBuilds()
    timestamps()

    }

    environment {
    IMAGE_NAME = "yf-csgods"
    IMAGE_TAG = "0.0.$BUILD_NUMBER"
    WS = "/home/ec2-user/workspace/csgods"
    ECR_REGISTRY = "352708296901.dkr.ecr.eu-central-1.amazonaws.com"

    }

    stages {
        stage('Build') {
            steps {
                sh 'echo building...'
                sh "cp FinalProject_KCSGODS/app/csgo_install.txt /var/lib/jenkins/workspace/yf-csgo-server/ServerBuild"
                sh '''
                aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
                docker build -t $IMAGE_NAME:$IMAGE_TAG . -f app/CSGODS.dockerfile


                '''
            }
        }

    stage('tag and push') {
        steps {
            sh'''
            docker tag $IMAGE_NAME:$IMAGE_TAG $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG
            docker push $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG
            '''
        }

        post {
            always {
            sh '''
            echo 'i have finished the job successfully'
            docker image prune -a -f --filter "until=24"
            '''
            }
        }
   }


        stage('Trigger Deploy ') {
            steps {
                build job: 'serverDeploy', wait: false, parameters: [
                    string(name: 'BOT_IMAGE_NAME', value: "${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}")
                ]
            }
        }
    }
}