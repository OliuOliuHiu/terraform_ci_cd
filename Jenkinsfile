// CREDENTIALS to create in Jenkins (Manage Jenkins > Credentials):
//   registry-creds  - Username with password        -> registry basic-auth user/pass
//   deploy-host     - Secret text                    -> private IP of the deploy server
//   build-agent-ssh - SSH Username with private key  -> SSH key into the deploy server

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
        echo "Will build & deploy image: ${env.IMAGE_REPO}:${env.IMAGE_TAG}"
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

# the run role reads these variables via lookup('env', ...)
export REGISTRY_HOST="$REGISTRY_HOST"
export REGISTRY_USERNAME="$REGISTRY_USR"
export REGISTRY_TOKEN="$REGISTRY_PSW"
# Deploy the exact image just built (by commit SHA), not relying on :latest
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
      echo "Deploy succeeded: ${env.IMAGE_REPO}:${env.IMAGE_TAG}"
    }
    failure {
      echo 'Pipeline failed — check the log of the red stage.'
    }
  }
}
