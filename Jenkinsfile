pipeline {
    agent any
    tools {

    maven 'maven'

    }
        stages {
            stage ('Checkout SCM') {
                steps {
                    checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/pttu1/devops-pipeline.git']]])
                }
            }

            stage ('Build') {
                steps {
                    dir('java-source'){sh "mvn package"}
                }
            }

            stage ('SonarQube Analysis') {
                steps {
                    withSonarQubeEnv('sonar') {
                        dir('java-source'){sh 'mvn -U clean install sonar:sonar -Dsonar.projectKey=ohwilly -Dsonar.host.url=http://3.142.151.76:9000 -Dsonar.login=01c7ce337d9555a4bdfd418de76208e4267063f1'}    
                    }
                }
            }

            stage ('Artifactory configuration') {
                steps {
                    rtServer (
                        id: "jfrog",
                        url: "http://18.117.87.152:8082/artifactory",
                        credentialsId: "jfrog"
                    )

                    rtMavenDeployer (
                        id: "MAVEN_DEPLOYER",
                        serverId: "jfrog",
                        releaseRepo: "libs-release-local",
                        snapshotRepo: "libs-snapshot-local"
                    )

                    rtMavenResolver (
                        id: "MAVEN_RESOLVER",
                        serverId: "jfrog",
                        releaseRepo: "libs-release",
                        snapshotRepo: "libs-snapshot"
                    )
                }
            }

            stage ('Deploy Artifacts') {
                steps {
                    rtMavenRun (
                        tool: "maven", //Tool name from Jenkins config
                        pom: 'java-source/pom.xml',
                        goals: 'clean install',
                        deployerId: "MAVEN_DEPLOYER",
                        resolverId: "MAVEN_RESOLVER"
                    )
                }
            }

            stage ('Publish build info') {
                steps {
                    rtPublishBuildInfo (
                        serverId: "jfrog"
                    )
                }
            }

            stage ('Copy Dockerfile & Playbook to Ansible Server') {
                steps {
                    sshagent(credentials: ['13d7f5c6-e22e-49f7-8618-0a8fb8638527']) {
                        //They are already cloned to the Jenkins local system
                        sh 'scp -o StrictHostKeyChecking=no Dockerfile ec2-user@18.218.41.93:/home/ec2-user'
                        sh 'scp -o StrictHostKeyChecking=no create-container-image.yaml ec2-user@18.218.41.93:/home/ec2-user'
                    }
                }
            }

            stage('Build Container Image') {
                steps {
                    sshagent(['sshkey']) {
                        sh "scp -o StrictHostKeyChecking=no ec2-user@18.218.41.93 -C \"sudo ansible-playbook create-container-image.yaml\""
                    }
                }
            }

            stage ('Copy Deployment & Service Manifest to the K8s Master') {
                steps {
                    sshagent(['sshkey']) {
                        sh "scp -o StrictHostKeyChecking=no create-k8s-deployment.yaml ec2-user@3.15.222.232:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no nodePort.yaml ec2-user@3.15.222.232:/home/ec2-user"
                    }
                }
            }

            stage ('Waiting for Approvals') {
                steps {
                    input('Test Completed? Please provide Approval for the Prod Release')
                }
            }

            stage ('Deploy Artifacts to Production') {
                steps {
                    sshagent([sshkey]) {
                        sh "scp -o StrictHostKeyChecking=no ec2-user@3.15.222.232 -C \"sudo kubectl apply -f create-k8s-deployment.yaml\""
                        sh "scp -o StrictHostKeyChecking=no ec2-user@3.15.222.232 -C \"sudo kubectl apply -f nodePort.yaml\""
                    }
                }
            }
        }

}
