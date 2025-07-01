pipeline {
  agent any

  stages {
    stage('Clone Repo') {
      steps {
        git branch: 'main', url: 'https://github.com/Teslim-Lawal/cloudnorth.git'
      }
    }

    stage('Clean Previous Containers') {
      steps {
        sh '''
          docker rm -f backend-container || true
          docker rm -f frontend-container || true
        '''
      }
    }

    stage('Build Backend') {
      steps {
        dir('backend') {
          sh 'docker build -t backend-app .'
        }
      }
    }

    stage('Build Frontend') {
      steps {
        dir('frontend') {
          sh 'docker build -t frontend-app .'
        }
      }
    }

    stage('Run Containers') {
      steps {
        sh 'docker run -d -p 5000:5000 --name backend-container backend-app'
        sh 'docker run -d -p 3000:3000 --name frontend-container frontend-app'
      }
    }
  }
}
