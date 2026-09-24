pipeline {
    agent any
    environment {
        ARM_CLIENT_ID       = credentials('azure-client-id')
        ARM_CLIENT_SECRET   = credentials('azure-secret-id')
        ARM_SUBSCRIPTION_ID = credentials('azure-subscription-id')
        ARM_TENANT_ID       = credentials('azure-tenant-id')
    }
    tools {
        // Yeh line automatically Terraform download aur configure kar degi
        terraform 'terraform-1.9.0' 
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        
        // "Setup Terraform" stage hata diya gaya hai!
        
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
$BACKEND_IP ansible_user=azureadmin ansible_ssh_common_args='-o StrictHostKeyChecking=no -J azureadmin@$FRONTEND_IP'

[database]
$DB_IP ansible_user=azureadmin ansible_ssh_common_args='-o StrictHostKeyChecking=no -J azureadmin@$FRONTEND_IP'
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
                        sh "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini deploy.yml --private-key=\$SSH_KEY"
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