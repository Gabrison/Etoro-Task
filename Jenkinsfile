pipeline {
  agent any

  parameters {
    choice(name: 'ACTION', choices: ['deploy', 'destroy'], description: 'Choose action: deploy or destroy')
  }

  environment {
    KUBECONFIG = "${WORKSPACE}/.kube/config"
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
        sh 'mkdir -p .kube'
        sh 'az login -i'
        sh 'az aks get-credentials -n devops-interview-aks -g devops-interview-rg --file .kube/config --overwrite-existing'
        sh 'kubelogin convert-kubeconfig -l msi'
      }
    }
    stage('Deploy') {
      when {
        expression { params.ACTION == 'deploy' }
      }
      steps {
        script {
          try {
            sh 'helm upgrade --install simple-web ./simple-web --namespace gabriel'
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
        script {
          try {
            sh 'helm uninstall simple-web --namespace gabriel'
          } catch (err) {
            echo "ERROR: ${err}"
            error('Destroy stage failed!')
          }
        }
      }
    }
  }
} 