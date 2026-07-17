// CI/CD cho NestJS app: build & push image -> deploy lên deploy server bằng Ansible (role run).
//
// Chạy trên BUILD SERVER (Jenkins SSH-launch agent, label 'build') — nơi có sẵn:
// docker, ansible, ssh, git. Image được đẩy lên REGISTRY TỰ-HOST (registry.internal:5000,
// TLS + basic auth native). Deploy server pull thẳng từ registry đó.
//
// Build server đã được ansible (role registry_client) chuẩn bị: /etc/hosts trỏ
// registry.internal -> app private IP, và CA nạp ở /etc/docker/certs.d/.
//
// Deploy server chỉ chạy container app, publish ra :3000. Không có nginx/TLS ở
// đó — nó nằm private subnet, nginx trên 'web' terminate TLS và proxy /app tới.
//
// CREDENTIALS cần tạo trong Jenkins (Manage Jenkins > Credentials):
//   registry-creds - Username with password  -> user/pass basic-auth của registry
//   deploy-host    - Secret text             -> private IP của deploy server
//   build-agent-ssh    - SSH Username with private key -> key SSH vào deploy server

pipeline {
  agent { label 'agent-builder' }

  options {
    timestamps()
    disableConcurrentBuilds()
    timeout(time: 30, unit: 'MINUTES')
  }

  environment {
    IMAGE_NAME    = 'nestjs-dev'
    REGISTRY_HOST = 'registry.internal:5000'
    REGISTRY      = credentials('registry-creds') // -> REGISTRY_USR, REGISTRY_PSW
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          env.IMAGE_REPO = "${REGISTRY_HOST}/${IMAGE_NAME}"
          env.IMAGE_TAG  = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        }
        echo "Sẽ build & deploy image: ${env.IMAGE_REPO}:${env.IMAGE_TAG}"
      }
    }

    stage('Build & Push image') {
      steps {
        sh '''
set -e
echo "$REGISTRY_PSW" | docker login "$REGISTRY_HOST" -u "$REGISTRY_USR" --password-stdin
docker build -t "$IMAGE_REPO:$IMAGE_TAG" -t "$IMAGE_REPO:latest" .
docker push "$IMAGE_REPO:$IMAGE_TAG"
docker push "$IMAGE_REPO:latest"
'''
      }
    }

    stage('Deploy with Ansible') {
      environment {
        DEPLOY_HOST = credentials('deploy-host')
      }
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: 'build-agent-ssh', keyFileVariable: 'SSH_KEY')]) {
          sh '''
set -e
mkdir -p ~/.ssh
ssh-keyscan -H "$DEPLOY_HOST" >> ~/.ssh/known_hosts 2>/dev/null || true

cat > ansible/inventory.ci.ini <<EOF
[app]
deploy_server ansible_host=$DEPLOY_HOST ansible_user=ubuntu ansible_ssh_private_key_file=$SSH_KEY ansible_python_interpreter=/usr/bin/python3
EOF

# role run đọc các biến này qua lookup('env', ...)
export REGISTRY_HOST="$REGISTRY_HOST"
export REGISTRY_USERNAME="$REGISTRY_USR"
export REGISTRY_TOKEN="$REGISTRY_PSW"
# Deploy đúng image vừa build (theo commit SHA), không phụ thuộc :latest
export APP_IMAGE="$IMAGE_REPO:$IMAGE_TAG"

ansible-playbook -i ansible/inventory.ci.ini ansible/deploy.yml
'''
        }
      }
    }
  }

  post {
    always {
      sh 'docker logout "$REGISTRY_HOST" || true'
    }
    success {
      echo "Deploy thành công: ${env.IMAGE_REPO}:${env.IMAGE_TAG}"
    }
    failure {
      echo 'Pipeline thất bại — kiểm tra log ở stage bị đỏ.'
    }
  }
}
