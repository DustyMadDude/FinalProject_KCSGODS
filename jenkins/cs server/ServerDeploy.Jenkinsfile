pipeline {
    agent {
        docker {
            // TODO build & push your Jenkins agent image, place the URL here
            image '352708296901.dkr.ecr.eu-central-1.amazonaws.com/yf-bot-reg:latest'
            args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        APP_ENV = "yf-csgo-server"
    }

    parameters {
        string(name: 'SERVER_IMAGE_NAME')
    }

    stages {
        stage('server Deploy') {
            steps {
                withCredentials([
                    string(credentialsId: 'steam-token', variable: 'SRCDS_TOKEN'),
                    file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')
                ]) {
                    sh "cp common/replaceInFile.sh /var/lib/jenkins/workspace/yf-csgo-server/ServerBuild"
                    sh '''
                    K8S_CONFIGS=infra/k8s

                    # replace placeholders in YAML k8s files
                    bash common/replaceInFile.sh $K8S_CONFIGS/deployment.yaml APP_ENV $APP_ENV
                    bash common/replaceInFile.sh $K8S_CONFIGS/deployment.yaml SERVER_IMAGE $SERVER_IMAGE_NAME
                    bash common/replaceInFile.sh $K8S_CONFIGS/deployment.yaml SRCDS_TOKEN $(echo -n $SRCDS_TOKEN | base64)

                    # apply the configurations to k8s cluster
                    kubectl apply --kubeconfig ${KUBECONFIG} -f $K8S_CONFIGS/deployment.yaml
                    '''
                }
            }
        }
    }
}