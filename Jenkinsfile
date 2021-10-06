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

            //stage ('SonarQube Analysis') {
                //steps {
                    //withSonarQubeEnv('sonar') {
                        //dir('java-source'){sh 'mvn -U clean install sonar:sonar -Dsonar.projectKey=ohwilly -Dsonar.host.url=http://3.143.212.41:9000 -Dsonar.login=d5f145f6e46cb28e90a6d3f975bf30736075f231'}    
                    //}
                //}
            //}

            stage ('Artifactory configuration') {
                steps {
                    rtServer (
                        id: "jfrog",
                        url: "http://18.222.229.112:9000",
                        credentialsId: "jfrog"
                    )

                    rtMavenDeployer (
                        id: "MAVEN_DEPLOYER",
                        serverId: "jfrog",
                        releaseRepo: "libs-release",
                        snapshotRepo: "libs-snapshot"
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
                    sshagent(['sshkey']) {
                        //They are already cloned to the Jenkins local system
                        sh "scp -o StrictHostKeyChecking=no Dockerfile ec2-user@18.118.165.26:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no create-container-image.yaml ec2-user@18.118.165.26:/home/ec2-user"
                    }
                }
            }

            stage('Build Container Image') {
                steps {
                    sshagent(['sshkey']) {
                        sh "scp -o StrictHostKeyChecking=no ec2-user@:3.144.43.28 -C \"sudo ansible-playbook create-container-image.yaml\""
                    }
                }
            }

            stage ('Copy Deployment & Service Manifest to the K8s Master') {
                steps {
                    sshagent(['sshkey']) {
                        sh "scp -o StrictHostKeyChecking=no create-k8s-deployment.yaml ec2-user@52.14.47.217:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no nodePort.yaml ec2-user@52.14.47.217:/home/ec2-user"
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
                        sh "scp -o StrictHostKeyChecking=no create-k8s-deployment.yaml ec2-user@52.14.47.217 -C \"sudo kubectl apply -f create-k8s-deployment.yaml\""
                        sh "scp -o StrictHostKeyChecking=no create-k8s-deployment.yaml ec2-user@52.14.47.217 -C \"sudo kubectl apply -f nodePort.yaml\""
                    }
                }
            }
        }

}