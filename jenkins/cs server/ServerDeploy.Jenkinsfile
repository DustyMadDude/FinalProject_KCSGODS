pipeline {
    agent {
        docker {
            image 'maven:3.6.3-jdk-8'
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
                    string(credentialsId: 'steam-token', variable: 'SRCDS_TOKEN')

                ]) {
                    sh '''
                    K8S_CONFIGS=infra/k8s

                    # replace placeholders in YAML k8s files
                    bash common/replaceInFile.sh $K8S_CONFIGS/deployment.yaml APP_ENV $APP_ENV
                    bash common/replaceInFile.sh $K8S_CONFIGS/secret.yaml APP_ENV $APP_ENV
                    bash common/replaceInFile.sh $K8S_CONFIGS/deployment.yaml SERVER_IMAGE $SERVER_IMAGE_NAME
                    bash common/replaceInFile.sh $K8S_CONFIGS/secret.yaml SRCDS_TOKEN $(echo -n $SRCDS_TOKEN | base64)

                    aws eks update-kubeconfig --region eu-central-1 --name csgods-k8s

                    # apply the configurations to k8s cluster
                    kubectl apply -f $K8S_CONFIGS/namespace.yaml
                    kubectl apply -f $K8S_CONFIGS/secret.yaml
                    kubectl apply -f $K8S_CONFIGS/configuration.yaml
                    kubectl apply -f $K8S_CONFIGS/deployment.yaml
                    kubectl apply -f $K8S_CONFIGS/service.yaml
                    '''
                }
            }
        }
    }
}
