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
    stage('Deploy or Destroy') {
      steps {
        script {
          try {
            if (params.ACTION == 'deploy') {
              sh 'helm upgrade --install simple-web ./simple-web --namespace gabriel'
            } else if (params.ACTION == 'destroy') {
              sh 'helm uninstall simple-web --namespace gabriel'
            }
          } catch (err) {
            echo "ERROR: ${err}"
            error('Deploy or Destroy stage failed!')
          }
        }
      }
    }
  }
} 