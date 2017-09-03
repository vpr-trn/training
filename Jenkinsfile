#!groovy

def buildversion = ''
def buildname = 'task4'
def buildfile = "${buildname}.war"
def gitbranch = 'task4'
def testserver = 'server1'
def replicas = 2

node ('master'){

  stage('Git-Clone'){
    checkout([$class: 'GitSCM', branches: [[name: "${gitbranch}"]], doGenerateSubmoduleConfigurations: false, userRemoteConfigs: [[credentialsId: 'GITHUB_SSH', url: 'git@github.com:vpr-trn/training.git']]])
  }

  stage('Build'){
    sh 'chmod +x gradlew'
    sh './gradlew increment --info'
    sh "./gradlew build -P buildfile=${buildfile} --info"
  }

  buildversion = GetVersion()
  echo "New version ${buildversion} "

  stage ('Archive'){
    // upload file to nexus
    withCredentials([usernamePassword(credentialsId: 'NEXUS_ID', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
      sh "curl --upload-file build/libs/$buildfile http://localhost:8081/nexus/content/repositories/snapshots/${gitbranch}/${buildversion}/${buildfile}"
    }
  }

  stage ('Create Docker Image'){
    // build docker image
    sh "docker build --build-arg GITBRANCH=${gitbranch} --build-arg BUILD=${buildversion} --build-arg FILE=${buildfile} -t 192.168.50.50:5000/${buildname}:${buildversion} ."
    sh "docker push 192.168.50.50:5000/${buildname}:${buildversion}"
  }

  stage ('Deploy to Swarm'){
    try {
      sh "docker service update --force --replicas ${replicas} --image 192.168.50.50:5000/${buildname}:${buildversion} ${buildname}"
    }
    catch(all){
      sh "docker service create --replicas ${replicas} --name ${buildname} --update-delay 10s -p 8099:8080 192.168.50.50:5000/${buildname}:${buildversion}"
    }
  }
}
  node("${testserver}"){
    stage("Test Deployment"){
      // waiting until full deployment
      sleep replicas*10+10
      // checking application version
      def response = httpRequest acceptType: 'TEXT_PLAIN', consoleLogResponseBody: true, contentType: 'TEXT_PLAIN', responseHandle: 'NONE', url: "http://localhost:8099/${buildname}"
      if (!response.content.contains(buildversion)){
        error ("Application deployment error on server${i}!")
      }
    }
  }

node ('master'){
  stage('Git-Release'){
    sh "git checkout ${gitbranch}"
    sh 'git add gradle.properties'
    sh 'git config user.email jenkins@mainserver.com'
    sh 'git config user.name jenkins'
    sh 'git commit -m "Added file with automated Jenkins job"'
    sshagent (credentials: ['GITHUB_SSH']){
      sh 'git push' 
    }
    sh 'git checkout master -f'
    sh "git merge ${gitbranch}"
    sh "git tag -a ${buildversion} -m \"Build version ${buildversion}\""
    sshagent (credentials: ['GITHUB_SSH']) {
      sh 'git push --tags'
      sh 'git push'
    }
  }
}

def GetVersion(){
  def props = readProperties  file: 'gradle.properties'
  return props['version']
}