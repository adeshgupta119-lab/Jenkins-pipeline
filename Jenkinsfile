pipeline {
    agent any
    environment {
        ARM_CLIENT_ID       = credentials('azure-client-id')
        ARM_CLIENT_SECRET   = credentials('azure-secret-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_TENANT_ID       = credentials('azure-tenant-id')
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Terraform Init') {
            steps {
                dir('environments/preprod') { sh 'terraform init' }
            }
        }
        stage('Terraform Plan') {
            steps {
                dir('environments/preprod') { sh 'terraform plan -out=tfplan' }
            }
        }
        stage('Approval') {
            when { branch 'main' }
            steps {
                input message: 'Approve Terraform Apply?', ok: 'Deploy'
            }
        }
        stage('Terraform Apply') {
            when { branch 'main' }
            steps {
                dir('environments/preprod') { sh 'terraform apply -auto-approve tfplan' }
            }
        }
        stage('Generate Dynamic Inventory') {
            when { branch 'main' }
            steps {
                dir('environments/preprod') {
                    sh '''
                    FRONTEND_IP=$(terraform output -json vm_ips | jq -r '.frontend')
                    BACKEND_IP=$(terraform output -json vm_ips | jq -r '.backend')
                    DB_IP=$(terraform output -json vm_ips | jq -r '.database')

                    cat > ../../ansible/inventory.ini <<EOF
[frontend]
$FRONTEND_IP ansible_user=azureadmin

[backend]
$BACKEND_IP ansible_user=azureadmin

[database]
$DB_IP ansible_user=azureadmin
EOF
                    '''
                }
            }
        }
        stage('Ansible Configure') {
            when { branch 'main' }
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'vm-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    dir('ansible') {
                        sh 'ansible-playbook -i inventory.ini deploy.yml --private-key=$SSH_KEY'
                    }
                }
            }
        }
    }
    post {
        success { echo 'Pipeline completed successfully' }
        failure { echo 'Pipeline failed - check logs' }
    }
}