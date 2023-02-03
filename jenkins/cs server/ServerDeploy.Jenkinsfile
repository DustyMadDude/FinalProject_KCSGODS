pipeline {
    agent {
        docker {
            image '352708296901.dkr.ecr.eu-central-1.amazonaws.com/yf-bot-reg:latest'
            args  '--user root -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        APP_ENV = "yf-csgo-server"
    }

    stages {
        stage('server Deploy') {
            steps {
                withCredentials([
                    string(credentialsId: 'steam-token', variable: 'SRCDS_TOKEN')

                ]) {
                    sh '''
                    K8S_CONFIGS=infra/k8s

                    # replace placeholders in YAML k8s files
                    bash common/replaceInFile.sh $K8S_CONFIGS/csgods.yaml APP_ENV $APP_ENV
                    bash common/replaceInFile.sh $K8S_CONFIGS/secret.yaml APP_ENV $APP_ENV
                    bash common/replaceInFile.sh $K8S_CONFIGS/namespace.yaml namespace $APP_ENV
                    bash common/replaceInFile.sh $K8S_CONFIGS/secret.yaml SRCDS_TOKEN $(echo -n $SRCDS_TOKEN | base64)

                    aws eks update-kubeconfig --region eu-central-1 --name csgods-k8s

                    # apply the configurations to k8s cluster
                    kubectl apply -f $K8S_CONFIGS/namespace.yaml
                    kubectl apply -f $K8S_CONFIGS/secret.yaml
                    kubectl apply -f $K8S_CONFIGS/csgods.yaml
                    kubectl apply -f $K8S_CONFIGS/service.yaml
                    '''
                }
            }
        }
    }
}
