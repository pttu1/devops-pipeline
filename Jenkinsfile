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
                        sh 'scp -o StrictHostKeyChecking=no Dockerfile ec2-user@52.14.53.24:/home/ec2-user'
                        sh 'scp -o StrictHostKeyChecking=no create-container-image.yaml ec2-user@52.14.53.24:/home/ec2-user'
                    }
                }
            }

            stage('Build Container Image') {
                steps {
                    sshagent(['sshkey']) {
                        sh "scp -o StrictHostKeyChecking=no ec2-user@52.14.53.24 -C \"sudo ansible-playbook create-container-image.yaml\""
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
