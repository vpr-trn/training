#!groovy

def buildversion = ''
def buildname = 'task3'
def buildfile = "${buildname}.war"
def gitbranch = 'task3'
def servernumber = 1

node ('master'){

  stage('Git-Clone'){
    checkout([$class: 'GitSCM', branches: [[name: 'task3']], doGenerateSubmoduleConfigurations: false, userRemoteConfigs: [[credentialsId: 'GITHUB_SSH', url: 'git@github.com:vpr-trn/training.git']]])
  }

  stage('Build'){
    sh 'chmod +x gradlew'
    sh './gradlew increment --info'
    sh "./gradlew build -P buildfile=${buildfile} --info"
    buildversion = GetVersion()
    echo "New version ${buildversion} "
  }

  stage ('Archive'){
    // upload file to nexus
    withCredentials([usernamePassword(credentialsId: 'NEXUS_ID', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]){
      sh "curl --upload-file build/libs/$buildfile http://localhost:8081/nexus/content/repositories/snapshots/${gitbranch}/${buildversion}/${buildfile}"
    }
  }
}

for (i=1;i<=servernumber;i++){
  node("server${i}"){
    stage("Deploy to tomcat${i}"){
      // download file from nexus
      httpRequest authentication: 'NEXUS_ID', url: "http://mainserver:8081/nexus/content/repositories/snapshots/${gitbranch}/${buildversion}/${buildfile}", outputFile: "${buildfile}"
      // stop tomcat
      sh "curl http://mainserver/jkmanager?cmd=update&w=lb&sw=worker${i}&vwa=2"
      // undeploy app
      httpRequest authentication: 'TOMCAT_ID', consoleLogResponseBody: true, responseHandle: 'NONE', url: "http://server${i}:8080/manager/text/undeploy?path=/${buildname}"
      // waiting 5 seconds until package uninstalled
      sleep 5
      // deploy into tomcat
      sh "cp ${buildfile} /usr/share/tomcat/webapps/"
      // waiting 10 seconds until package installed
      sleep 10
      // checking application version
      def response = httpRequest acceptType: 'TEXT_PLAIN', consoleLogResponseBody: true, contentType: 'TEXT_PLAIN', responseHandle: 'NONE', url: "http://server${i}:8080/${buildname}"
      if (!response.content.contains(buildversion)){
        error ("Application deployment error on server${i}!")
      }
      // start tomcat
      sh "curl http://mainserver/jkmanager?cmd=update&w=lb&sw=worker${i}&vwa=0"
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