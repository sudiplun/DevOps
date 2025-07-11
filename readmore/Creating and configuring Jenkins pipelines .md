Jenkins Pipelines are the core of modern CI/CD automation with Jenkins. They allow you to define your entire delivery pipeline (from code commit to deployment) as code, typically in a file called `Jenkinsfile`, which is then version-controlled alongside your source code.

-----

## Creating and Configuring Jenkins Pipelines

### 1\. Introduction to Jenkins Pipelines (Beginner - Theory)

  * **What is a Jenkins Pipeline?**
    A Jenkins Pipeline is a suite of plugins that supports implementing and integrating Continuous Delivery Pipelines into Jenkins. It's designed to be a durable, extensible, and self-serving automation server. The key idea is "Pipeline as Code," meaning the entire workflow is defined in a script.

  * **Why use Pipelines?**

      * **Version Control:** The pipeline definition (`Jenkinsfile`) lives in your SCM (Git, SVN), just like your application code. This means changes to the pipeline are tracked and reviewed.
      * **Consistency & Reproducibility:** Every build follows the exact same defined steps, ensuring consistent results across different runs and environments.
      * **Complex Workflows:** Easily model complex sequences of tasks, including parallel execution, conditional logic, and manual approvals.
      * **Visualization:** Jenkins provides a visual representation of the pipeline's progress, showing which stages are running, succeeding, or failing.
      * **Durability:** Pipelines can survive Jenkins master restarts.

  * **`Jenkinsfile`:**
    This is the text file (usually named `Jenkinsfile` without an extension) where your pipeline's definition is written. It's written in Groovy syntax.

  * **Scripted vs. Declarative Pipeline Syntax:**
    Jenkins Pipelines support two syntaxes:

      * **Declarative Pipeline:** (Recommended for most users) A modern, more opinionated, and structured syntax that provides a simpler way to create pipelines. It's easier to read and learn.
      * **Scripted Pipeline:** (More programmatic) A more flexible, Groovy-based syntax that offers greater control and power. It's executed directly on the Jenkins master or agents. Use it for complex logic that Declarative cannot express.

### 2\. Core Pipeline Concepts (Beginner - Theory)

  * **Stage:**
    A logical grouping of steps that represents a part of the continuous delivery process. Examples: "Build," "Test," "Deploy," "Approve." Stages are displayed visually in Jenkins's Stage View.

  * **Step:**
    A single task or command executed within a stage. Steps are the smallest unit of work in a pipeline. Examples: `sh 'mvn clean install'`, `git clone`, `echo 'Hello'`, `archiveArtifacts`.

  * **Node / Agent:**
    Refers to a machine (physical server, VM, container) where a pipeline or a specific part of a pipeline will run. `agent` is the Declarative term for a node. The Jenkins master can also act as an agent.

  * **SCM (Source Code Management):**
    The system (e.g., Git, Subversion) where your application code and your `Jenkinsfile` reside. Pipelines are usually triggered by changes in SCM.

### 3\. Creating a Basic Declarative Pipeline (Practical - Step-by-Step)

This will create a simple pipeline that builds, tests, and deploys a hypothetical application.

**Prerequisites:**

  * A running Jenkins instance.
  * Necessary Jenkins plugins installed (e.g., **Git**, **Pipeline**, **Pipeline: SCM Step**, **Workspace Cleanup** - most are suggested by default).
  * A Git repository (e.g., on GitHub, GitLab, Bitbucket) containing a `Jenkinsfile`.

**Let's assume you have a simple project structure in your Git repo:**

```
my-project/
├── Jenkinsfile
├── src/
└── pom.xml (if Java Maven project)
```

**Content of `my-project/Jenkinsfile` (Declarative):**

```groovy
// Jenkinsfile
pipeline {
    // Defines where the entire pipeline will run.
    // 'any' means Jenkins can use any available agent/node.
    agent any

    // Environment variables that apply to the entire pipeline.
    environment {
        APP_NAME = 'my-web-app'
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk' // Example, configure with Jenkins Tools
    }

    // Define the sequence of stages
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out source code...'
                // Checks out the code from the SCM defined in the job configuration
                git credentialsId: 'github-credentials', url: 'https://github.com/your-org/my-project.git'
                // Replace 'github-credentials' with your actual Jenkins credential ID if needed
            }
        }

        stage('Build') {
            steps {
                echo 'Building the application...'
                // Example for a Maven project
                sh "mvn clean install -DskipTests"
                // For Node.js: sh "npm install" or "npm run build"
                // For Python: sh "pip install -r requirements.txt"
            }
        }

        stage('Test') {
            steps {
                echo 'Running tests...'
                // Example for a Maven project (running tests)
                sh "mvn test"
                // For Node.js: sh "npm test"
                // For Python: sh "pytest"
            }
        }

        stage('Archive Artifacts') {
            steps {
                echo 'Archiving build artifacts...'
                // Archives the generated JAR/WAR file or other build output
                // Example for Maven:
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                // Adjust based on your project's output
            }
        }

        stage('Deploy to Staging') {
            // Optional: Run this stage only if the current branch is 'main'
            when { branch 'main' }
            steps {
                echo "Deploying ${APP_NAME} to staging environment..."
                // Example: Copy artifact to a staging server via SSH
                sh "scp target/*.jar user@staging-server:/opt/my-app/"
                // Or deploy to a Kubernetes cluster
                // sh "kubectl apply -f k8s/staging-deployment.yaml"
            }
        }
    }

    // Post-build actions, executed after all stages are complete.
    // Use 'always', 'success', 'failure', etc., for conditional execution.
    post {
        always {
            echo 'Pipeline finished. Cleaning up workspace...'
            // Clean workspace to ensure a fresh build next time
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded! Sending notification...'
            // mail to: 'devs@example.com', subject: "Build ${currentBuild.displayName} Succeeded!"
        }
        failure {
            echo 'Pipeline failed! Sending alert...'
            // mail to: 'devs@example.com', subject: "Build ${currentBuild.displayName} FAILED!", body: "Check ${env.BUILD_URL}"
        }
    }
}
```

**Setting up the Jenkins Job:**

1.  **Log in to Jenkins.**
2.  On the Jenkins dashboard, click **"New Item"** in the left-hand menu.
3.  Enter an **Item name** (e.g., `my-first-pipeline`).
4.  Select **"Pipeline"** as the type. Click **"OK."**
5.  On the job configuration page:
      * **General:** Add an optional description. Check "GitHub project" and paste your Git repository URL if it's on GitHub.
      * **Build Triggers:** For now, leave as default. Later, you'll configure webhooks.
      * **Pipeline:**
          * Select **"Pipeline script from SCM."**
          * **SCM:** Select **"Git."**
          * **Repository URL:** Enter the HTTPS or SSH URL of your Git repository (e.g., `https://github.com/your-org/my-project.git`).
          * **Credentials:** If your repository is private, click "Add" -\> "Jenkins" to add your Git username/password or SSH key. Select the appropriate credential ID.
          * **Branches to build:** `*/main` (or `*/master`, or your feature branch).
          * **Script Path:** Enter `Jenkinsfile` (this is the default, ensure your file is named exactly this in the repo root).
6.  Click **"Save."**

**Running the Pipeline:**

1.  On your newly created pipeline job's page, click **"Build Now"** in the left-hand menu.
2.  A new build will start in the Build History section. Click on the build number (e.g., `#1`).
3.  Click **"Console Output"** to see the detailed logs of the pipeline execution.
4.  Click **"Stage View"** to see a visual representation of your pipeline's stages and their status.

### 4\. Intermediate Declarative Pipeline Features (Practical & Theory)

  * **`agent` options:**

      * **`agent { label 'my-linux-agent' }`:** Run on a specific agent node with a given label.
      * **`agent { docker { image 'node:18-alpine' } }`:** Run the pipeline steps inside a Docker container (Jenkins will launch the container on an available agent). This is excellent for ensuring consistent build environments.
      * You can also specify `agent` at the `stage` level to run different stages on different agents or in different containers.
        ```groovy
        stage('Build with Maven') {
            agent { docker { image 'maven:3.8.7-openjdk-17' } }
            steps {
                sh "mvn clean install"
            }
        }
        ```

  * **Environment Variables (`environment`):**

      * **Global:** Defined at the top level `pipeline` block, apply to all stages.
      * **Stage-specific:** Defined within a `stage` block, apply only to that stage.
      * **Example:** (Already shown in basic example) Access using `env.VAR_NAME`.

  * **Post-build Actions (`post`):**

      * **`always`:** Runs regardless of pipeline status.
      * **`success`:** Runs only if the pipeline succeeds.
      * **`failure`:** Runs only if the pipeline fails.
      * **`unstable`:** Runs if the pipeline is unstable (e.g., tests failed but the build passed).
      * **`changed`:** Runs if the current build status is different from the previous one.
      * **`fixed`:** Runs if the current build succeeds and the previous one failed or was unstable.
      * **`aborted`:** Runs if the pipeline was manually aborted.
      * **Common actions:** `archiveArtifacts`, `junit`, `mail`, `cleanWs`.

  * **Parameters (`parameters`):**

      * Allows users to provide input when triggering a build.
      * **Types:** `string`, `booleanParam`, `choice`, `text`, `password`.
      * **Accessing:** Parameters are available in the `params` object (e.g., `params.MY_PARAM`).
      * **`Jenkinsfile` example:**
        ```groovy
        pipeline {
            agent any
            parameters {
                string(name: 'BRANCH_TO_BUILD', defaultValue: 'main', description: 'Which branch to build?')
                booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests during build?')
            }
            stages {
                stage('Build') {
                    steps {
                        echo "Building branch: ${params.BRANCH_TO_BUILD}"
                        script {
                            if (params.SKIP_TESTS) {
                                sh "mvn clean install -DskipTests"
                            } else {
                                sh "mvn clean install"
                            }
                        }
                    }
                }
            }
        }
        ```
        When you run this, Jenkins will present a form for input.

  * **Credentials (`credentials`):**

      * Jenkins' Credentials Plugin securely stores sensitive data (passwords, SSH keys, secrets).
      * Use `withCredentials` step to access them in your pipeline.
      * **`Jenkinsfile` example:**
        ```groovy
        // Assuming you have a 'my-ssh-key' credential (SSH Username with private key)
        stage('Deploy via SSH') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'my-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    sh "ssh -i \${SSH_KEY} user@remote-server 'ls /var/www'"
                }
            }
        }
        // Assuming you have a 'my-docker-hub-creds' credential (Username with password)
        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                }
            }
        }
        ```

  * **Tools (`tools`):**

      * Allows referencing tools (like Maven, JDK, Node.js) configured in Jenkins' Global Tool Configuration. Jenkins will ensure the correct version is available in the `PATH` during the stage.
      * **`Jenkinsfile` example:**
        ```groovy
        pipeline {
            agent any
            tools {
                maven 'Maven 3.8.7' // Name configured in Manage Jenkins -> Tools
                jdk 'JDK 17'        // Name configured in Manage Jenkins -> Tools
            }
            stages {
                stage('Build') {
                    steps {
                        sh "mvn clean install" // Maven command available directly
                    }
                }
            }
        }
        ```

  * **Triggers (`triggers`):**

      * Define when the pipeline should automatically run.
      * **`cron`:** For scheduled builds (e.g., nightly builds).
        ```groovy
        triggers {
            cron 'H 0 * * *' // Runs once daily at an arbitrary time
        }
        ```
      * **`pollSCM`:** (Older, less efficient) Periodically polls the SCM for changes. **Webhooks are preferred.**
        ```groovy
        triggers {
            pollSCM '* * * * *' // Every minute (not recommended for production)
        }
        ```
      * **Webhooks (Recommended):** The most efficient way to trigger. Your SCM (GitHub, GitLab, Bitbucket) sends an HTTP POST request to Jenkins whenever a commit occurs.
        1.  In your Jenkins job config, under **Build Triggers**, select "GitHub hook trigger for GITScm polling" or "Generic Webhook Trigger" depending on your SCM.
        2.  Configure the webhook URL in your Git repository's settings, pointing to your Jenkins URL (`http://your-jenkins-url/github-webhook/` or similar).

### 5\. Scripted Pipeline Overview (Intermediate - Theory)

  * **Syntax:** More like traditional Groovy scripting. It's built around `node {}` blocks and `stage()` steps, but offers more imperative control.
  * **When to Use:**
      * Highly dynamic pipelines where decisions need to be made based on complex logic during runtime.
      * Advanced error handling or loop constructs.
      * When you need to interact with Jenkins APIs directly.
  * **Basic Structure:**
    ```groovy
    // Scripted Pipeline
    node {
        stage('Checkout') {
            // Steps here
        }
        stage('Build') {
            // Steps here
            try {
                sh 'mvn clean install'
            } catch (Exception e) {
                echo "Build failed: ${e.getMessage()}"
                currentBuild.result = 'FAILURE'
                error("Build process encountered an error.")
            }
        }
        // More complex logic possible
        if (env.BRANCH_NAME == 'main') {
            stage('Deploy to Prod') {
                // ...
            }
        }
    }
    ```
  * **Why Declarative is generally preferred:** Declarative is simpler, more readable, and safer due to its stricter structure. For most common CI/CD patterns, Declarative is sufficient. Use Scripted only when you truly need its programmatic flexibility, or encapsulate complex Scripted logic within Shared Libraries.

### 6\. Advanced Pipeline Concepts & Best Practices (Expert - Theory & Practical)

  * **Shared Libraries:**

      * **Theory:** A powerful feature that allows you to define reusable pipeline code, functions, and steps outside of individual `Jenkinsfiles`. They live in separate Git repositories and are loaded into your pipelines.
      * **Benefits:**
          * **Standardization:** Enforce consistent pipeline patterns across projects.
          * **Modularity & Reusability:** Write code once, use it everywhere.
          * **Maintainability:** Update pipeline logic in one place.
          * **DRY (Don't Repeat Yourself):** Avoid copy-pasting code across `Jenkinsfiles`.
      * **Practical:**
        1.  **Structure:** `vars/` (for global variables/functions), `src/` (for classes), `resources/` (for non-Groovy files).
        2.  **Configuration:** In **Manage Jenkins \> System \> Global Pipeline Libraries**, add your Shared Library Git repository.
        3.  **Usage in Jenkinsfile:**
            ```groovy
            // In Jenkinsfile
            @Library('my-shared-library') _ // Load the library
            mySharedSteps.buildAndTestApp() // Call a function from the library
            ```

  * **Nested Stages / Parallel Stages:**

      * **`parallel` block:** Execute multiple stages or steps concurrently. Ideal for running different types of tests (unit, integration, linting) at the same time.
      * **`Jenkinsfile` example:**
        ```groovy
        stages {
            stage('Test') {
                parallel {
                    stage('Unit Tests') {
                        steps { sh 'mvn test -Dgroups=unit' }
                    }
                    stage('Integration Tests') {
                        steps { sh 'mvn test -Dgroups=integration' }
                    }
                    stage('Lint Code') {
                        steps { sh 'npm run lint' }
                    }
                }
            }
        }
        ```

  * **Conditional Execution (`when {}`):**

      * Allows stages to run only when certain conditions are met (e.g., branch name, environment variable presence, changes in specific files).
      * **`Jenkinsfile` example:** (Already shown in basic example for `branch 'main'`)
        ```groovy
        stage('Deploy to Prod') {
            when {
                branch 'main' // Only run if on 'main' branch
                environment name: 'DEPLOY_TO_PROD', value: 'true' // And if DEPLOY_TO_PROD env var is 'true'
            }
            steps {
                echo 'Deploying to production!'
            }
        }
        ```

  * **Error Handling & Retries:**

      * **`options { retry(n) }` (Declarative):** Retries a stage or step `n` times if it fails.
        ```groovy
        stage('Flaky Test') {
            options {
                retry(3) // Retry this stage up to 3 times on failure
            }
            steps {
                sh 'run_flaky_test.sh'
            }
        }
        ```
      * **`try/catch/finally` (Scripted):** For more fine-grained error control.

  * **Timeout:**

      * `options { timeout(time: 10, unit: 'MINUTES') }` sets a maximum duration for the pipeline or a stage.

  * **Input Steps (`input`):**

      * Pause the pipeline execution and wait for manual approval or input.
      * **`Jenkinsfile` example:**
        ```groovy
        stage('Manual Approval for Production') {
            steps {
                input(id: 'proceed-to-prod', message: 'Ready to deploy to production?')
                echo 'Approved! Proceeding with production deployment...'
            }
        }
        ```

  * **Security in Pipelines:**

      * **Credential Masking:** Jenkins automatically masks credentials used in `withCredentials` in the console output.
      * **Pipeline Sandbox:** Declarative pipelines run in a Groovy sandbox, limiting what code can do by default for security. Scripted pipelines might require more configuration (e.g., "Approve Groovy sandbox access" by an administrator for custom methods).
      * **Least Privilege:** Ensure Jenkins users and the Jenkins service account itself have only the necessary permissions.

  * **Pipeline Best Practices:**

      * **Version Control `Jenkinsfile`:** Always commit your `Jenkinsfile` to your SCM.
      * **Fast Feedback:** Keep stages short and ensure tests run quickly. Prioritize unit tests in CI.
      * **Idempotency:** Design pipeline steps to be repeatable without side effects if run multiple times.
      * **Stateless Agents:** Don't rely on files or state persisting on agents between builds. Clean up the workspace.
      * **Avoid `sh` for complex logic:** For anything more complex than a single shell command, write a Groovy function in a Shared Library.
      * **Clean Up:** Use `post { always { cleanWs() } }` to ensure your workspace is clean after every build.
      * **Don't hardcode secrets:** Use Jenkins Credentials for all sensitive information.

Creating and configuring Jenkins Pipelines effectively transforms your software delivery process, making it more reliable, efficient, and transparent.