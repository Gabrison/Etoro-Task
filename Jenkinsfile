pipeline {
  agent any

  parameters {
    choice(name: 'ACTION', choices: ['deploy', 'destroy'], description: 'Choose action: deploy or destroy')
  }

  environment {
    KUBECONFIG = "${HOME}/.kube/config"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }
    stage('Azure Login & AKS Auth') {
      steps {
        sh 'az login -i'
        sh 'az aks get-credentials -n devops-interview-aks -g devops-interview-rg'
        sh 'kubelogin convert-kubeconfig -l msi'
      }
    }
    stage('Deploy or Destroy') {
      steps {
        script {
          if (params.ACTION == 'deploy') {
            sh 'helm upgrade --install simple-web ./simple-web --namespace gabriel'
          } else if (params.ACTION == 'destroy') {
            sh 'helm uninstall simple-web --namespace gabriel'
          }
        }
      }
    }
  }
} 