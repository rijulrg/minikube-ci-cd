def sonarqube(projectName, projectKey){
	def sonarqubeScannerHome = tool name: 'sonar', type: 'hudson.plugins.sonar.SonarRunnerInstallation' 
	withSonarQubeEnv("sonarqube-server"){
		withCredentials([string(credentialsId: 'sonar', variable: 'sonarLogin')]) {
			// sh "npm install typescript"
			sh "${sonarqubeScannerHome}/bin/sonar-scanner -Dsonar.exclusions=node_modules/** -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${sonarLogin} -Dsonar.projectName=${projectName} -Dsonar.projectKey=${projectKey}"
		}
	}
}

def qualityGate(){
	sh "sleep 10"
	Integer maxRetry = 6
    for (i=0; i<maxRetry; i++){
    try {
        timeout(time: 10, unit: 'SECONDS') {
        def qg = waitForQualityGate()
        if (qg.status != 'OK') {
            error "Sonar quality gate status: ${qg.status}"
        	} 
        else {
            i = maxRetry
        	}
		}
	} catch(Exception e) {
        if (i == maxRetry-1) {
            throw e
            }
        }
    }
}

def dockerBuildPush(imageName){
	docker.withRegistry('https://index.docker.io/v1/') {
	def app = docker.build( "${imageName}", '.').push()
	}
	sh 'sleep 2'
	sh "docker rmi ${imageName}"
}

def deploymentK8s(commitId,deploymentName,imageName){
	withKubeConfig([credentialsId: 'kubernetesMinikube']) {    	
		sh "cat k8s/deployment.yaml | sed 's/{{COMMIT_ID}}/${commitId}/g' | kubectl apply -f -"
		sh "kubectl annotate deployment ${deploymentName} kubernetes.io/change-cause='${imageName}' --record=false --overwrite=true"
		sh 'kubectl apply -f k8s/service.yaml'
	}
}
def test(){
	def myTestContainer = docker.image('node:10')
        myTestContainer.pull()
        myTestContainer.inside {    
            sh 'npm install --only=dev'
            sh 'npm test'
            }
}

node {
    def commitId 
	def dev_email
    def dev_name
	def deploymentName = "frontend-admin-service -n exchange-frontend"
	def imageName = "rijulrg/test:${commitId}"
	def projectName = "honest_food_task"
	def projectKey = "hft"
    def PROJECT_NAME = 'Honest Food Task'

    stage('SCM') {
		cleanWs()
        checkout scm 
        sh 'git rev-parse --short HEAD > .git/commit-id'
        commitId = readFile('.git/commit-id').trim()
		dev_email = sh(script: "git --no-pager show -s --format='%ae'", returnStdout: true).trim()
		dev_name = sh(script: "git --no-pager show -s --format='%an'", returnStdout: true).trim()		
        }
	try{
		stage('Test') {
			test()
		}
			
		stage('Sonar-Scanner') {
			sonarqube("${projectName}", "${projectKey}")
		}
			
		stage('Quality Gate'){
			qualityGate()
		}
			
		stage('Docker Build/Push Cleanup') {
			dockerBuildPush("${imageName}")
		}

		stage('Deployment') {
            STAGE=env.STAGE_NAME
			deploymentK8s("${commitId}", "${deploymentName}", "${imageName}")	
		}
	} catch(error){
        sh "echo ${error}"
	}	
}
