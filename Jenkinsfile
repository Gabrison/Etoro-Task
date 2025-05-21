pipeline {
  agent any

  parameters {
    choice(name: 'ACTION', choices: ['deploy', 'destroy'], description: 'Choose action: deploy or destroy')
  }

  environment {
    KUBECONFIG = "${WORKSPACE}/.kube/config"
    NAMESPACE = "gabriel"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'git log -1'
      }
    }
    stage('Azure Login & AKS Auth') {
      steps {
        echo "[INFO] Logging in to Azure and configuring AKS credentials..."
        sh 'mkdir -p .kube'
        sh 'az login -i'
        sh 'az aks get-credentials -n devops-interview-aks -g devops-interview-rg --file .kube/config --overwrite-existing'
        sh 'kubelogin convert-kubeconfig -l msi'
      }
    }
    stage('Lint & Dry Run') {
      steps {
        echo "[INFO] Running Helm lint..."
        sh 'helm lint ./simple-web'
      }
    }
    stage('Deploy') {
      when {
        expression { params.ACTION == 'deploy' }
      }
      steps {
        echo "[INFO] Deploying to namespace: ${env.NAMESPACE}"
        script {
          try {
            sh 'helm upgrade --install simple-web ./simple-web --namespace ${NAMESPACE}'
          } catch (err) {
            echo "ERROR: ${err}"
            error('Deploy stage failed!')
          }
        }
      }
    }
    stage('Destroy') {
      when {
        expression { params.ACTION == 'destroy' }
      }
      steps {
        echo "[INFO] Destroying release in namespace: ${env.NAMESPACE}"
        script {
          try {
            sh 'helm uninstall simple-web --namespace ${NAMESPACE}'
          } catch (err) {
            echo "ERROR: ${err}"
            error('Destroy stage failed!')
          }
        }
      }
    }
  }
  post {
    always {
      echo "[INFO] Cleaning up kubeconfig and sensitive files..."
      sh 'rm -rf .kube'
    }
  }
} 