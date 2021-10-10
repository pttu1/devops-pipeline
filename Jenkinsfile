pipeline {
    agent any
        stages {
            stage ('Checkout SCM') {
                steps {
                    checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/pttu1/devops-pipeline.git']]])
                }
            }

            stage ('Copy Dockerfile & Playbook to Ansible Server') {
                steps {
                    sshagent(['sshkey']) {
                        //They are already cloned to the Jenkins local system
                        sh 'scp -o StrictHostKeyChecking=no Dockerfile admin@18.220.201.221:/home/admin'
                        sh 'scp -o StrictHostKeyChecking=no create-container-image.yaml admin@18.220.201.221:/home/admin'
                    }
                }
            }

            stage('Build Container Image') {
                steps {
                    sshagent(['sshkey']) {
                        //sh "ssh admin@18.220.201.221 -C \"ansible-playbook create-container-image.yaml\""
                        sh "ssh admin@18.220.201.221 -C \"echo 'hello world!'""
                    }
                }
            }


            stage ('Waiting for Approvals') {
                steps {
                    input('Test Completed? Please provide Approval for the Prod Release')
                }
            }
            
        }

}
