pipeline{
    agent {
        label 'demo-node'
    }

    environment {
        PLAN_FILE = 'app'
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REGISTRY = '114277274749.dkr.ecr.us-east-1.amazonaws.com'
        ECR_NAME = 'gorilla-timeoff'
        IMAGE_NAME = 'timeoff'
        IMAGE_TAG = 'latest'
        UPDATE_APP = true
        DESTROY_INFRA = false
        CLUSTER_NAME = "timeoff-cluster"
        SERVICE_NAME = "timeoff-service"
        DOMAIN_NAME = "timeoff-example.link"
    }
    stages{
        stage("ECR Provision"){
            steps{
                echo "======== AWS ECR provision with Terraform ========"
                sh """
                cd ${env.WORKSPACE}/terraform/ecr/
                terraform init
                terraform plan -out ${PLAN_FILE}.tfplan
                terraform apply ${PLAN_FILE}.tfplan
                """
            }
        }
        stage("Build Image Stage"){
            steps{
                echo "======== Building Docker Image ========"
                sh """
                sudo docker system prune -af
                sudo docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                sudo docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_NAME}:${IMAGE_TAG}
                """
            }
        }
        stage("Deploy Image Stage"){
            steps{
                echo "======== Deploying Docker Image to ECR ========"
                sh """
                aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | sudo docker login --username AWS --password-stdin ${ECR_REGISTRY}
                sudo docker push ${ECR_REGISTRY}/${ECR_NAME}:${IMAGE_TAG}
                """
            }
        }
        stage("Deploy Application"){
            steps{
                echo "======== Deploying Infrastructure using Terraform ========"
                sh """
                cd ${env.WORKSPACE}/terraform/fargate/
                terraform init
                terraform plan -out ${PLAN_FILE}.tfplan
                terraform apply ${PLAN_FILE}.tfplan
                echo '=== HTTP URL: http://${DOMAIN_NAME} - HTTPS URL: https://${DOMAIN_NAME} ==='
                """
            }
        }
        stage("Update Application"){
            steps{
                script{
                    if(UPDATE_APP.toBoolean()){
                        echo "======== Updating application in ECS ========"
                        sh """
                        aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --force-new-deployment
                        """
                    }else{
                        sh """
                        echo 'Skipping update process because variable is false'
                        """
                    }
                }
            }
        }
        stage("Destroy Infrastructure") {
            steps{
                script{
                    if(DESTROY_INFRA.toBoolean()){
                        echo "======== Updating application in ECS ========"
                        sh """
                        cd ${env.WORKSPACE}/terraform/fargate/
                        terraform destroy -auto-approve
                        cd ${env.WORKSPACE}/terraform/ecr/
                        terraform destroy -auto-approve
                        """
                    }else{
                        sh """
                        echo 'Skipping destroy process because variable is false'
                        """
                    }
                }
            }
        }
    }
}