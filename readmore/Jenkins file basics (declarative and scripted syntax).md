A **Jenkinsfile** is a text file that defines your entire Jenkins Pipeline as code. Instead of configuring your CI/CD workflow through the Jenkins web UI, you write the steps, stages, and logic directly into this file, which is then committed to your project's Source Code Management (SCM) repository (like Git) alongside your application code. This approach is known as "Pipeline as Code" and brings numerous benefits:

  * **Version Control:** The pipeline's definition is tracked, reviewed, and audited like any other code.
  * **Consistency:** Every build follows the same defined process, ensuring consistent results.
  * **Collaboration:** Teams can collaborate on pipeline improvements through standard code review processes.
  * **Reusability:** Pipeline logic can be reused across multiple projects or branches.
  * **Disaster Recovery:** If your Jenkins instance fails, you can easily recreate pipelines from your SCM.

Jenkins supports two main syntaxes for writing a `Jenkinsfile`: **Declarative** and **Scripted**. Both are built on Groovy, but they offer different levels of structure and flexibility.

-----

### 1\. Declarative Pipeline Syntax

**Characteristics:**

  * **Structured:** Highly opinionated and structured syntax. It provides predefined blocks and directives that guide how you define your pipeline.
  * **Easier to Learn and Read:** Its more rigid structure makes it simpler for newcomers and generally easier to understand at a glance.
  * **Less Flexible Programmatically:** It's not a general-purpose programming language; you work within its defined syntax. For complex Groovy logic, you often need to use a `script` block.
  * **Validation:** Jenkins can perform syntax validation before execution, catching errors early.
  * **Blue Ocean Support:** Integrates well with the Jenkins Blue Ocean UI for visual pipeline representation.

**Basic Structure:**

A Declarative Pipeline always starts with a `pipeline` block and contains several mandatory and optional directives.

```groovy
// Jenkinsfile (Declarative Syntax)

pipeline {
    // 1. agent: Defines where the entire pipeline or a specific stage will run.
    // 'any' means Jenkins can use any available agent/node.
    // Other options: 'none', 'label', 'docker', 'kubernetes', etc.
    agent any

    // 2. stages: Contains one or more 'stage' blocks.
    stages {
        // 3. stage: A logical grouping of steps, representing a phase of the pipeline.
        stage('Build') {
            // 4. steps: Contains one or more 'steps' to be executed in this stage.
            steps {
                echo 'Building the application...' // An example step: prints a message
                sh 'mvn clean install -DskipTests' // Shell command for a Maven project
            }
        }

        stage('Test') {
            steps {
                echo 'Running unit tests...'
                sh 'mvn test' // Shell command to run tests
            }
        }

        // Optional: A stage that only runs under certain conditions
        stage('Deploy to Production') {
            // 5. when: Directive to define conditions for stage execution.
            when {
                branch 'main' // Only run this stage if the branch is 'main'
                environment name: 'DEPLOY_PROD', value: 'true' // And if an environment variable is set
            }
            steps {
                echo 'Deploying to production environment...'
                // Add deployment commands here
            }
        }
    }

    // 6. post: Defines actions to be executed after the pipeline (or a stage) completes,
    // based on the build status (success, failure, always, etc.).
    post {
        always {
            echo 'Pipeline finished. Cleaning up workspace.'
            cleanWs() // Jenkins step to clean the workspace
        }
        success {
            echo 'Pipeline succeeded! Notifying team...'
            // mail to: 'dev@example.com', subject: 'Pipeline Success'
        }
        failure {
            echo 'Pipeline failed! Sending alert...'
            // mail to: 'ops@example.com', subject: 'Pipeline Failure'
        }
    }

    // 7. environment: Defines environment variables accessible throughout the pipeline.
    // Can also be defined per stage.
    environment {
        APP_NAME = 'MyWebApp'
        BUILD_TOOL_VERSION = '1.0'
    }

    // 8. parameters: Defines build parameters that a user can set when triggering the build.
    parameters {
        string(name: 'BUILD_ENV', defaultValue: 'dev', description: 'Environment to build for')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip all tests?')
    }

    // 9. tools: Automatically installs and makes tools available (e.g., Maven, JDK, Node.js)
    // based on configurations in Manage Jenkins -> Global Tool Configuration.
    tools {
        maven 'Maven 3.8.7' // 'Maven 3.8.7' must be a defined tool name in Jenkins
        jdk 'JDK 17'        // 'JDK 17' must be a defined tool name in Jenkins
    }

    // 10. options: Configures pipeline-specific options (e.g., build discarders, timeouts, retries).
    options {
        buildDiscarder(logRotator(numToKeepStr: '10')) // Keep last 10 builds
        timeout(time: 1, unit: 'HOURS') // Max pipeline runtime
        timestamps() // Prefix console output with timestamps
    }
}
```

### 2\. Scripted Pipeline Syntax

**Characteristics:**

  * **Groovy-based:** It's essentially a general-purpose Groovy script that is executed by Jenkins.
  * **Highly Flexible:** Offers full programmatic control over the pipeline flow. You can use standard Groovy constructs like `if/else`, loops, `try/catch` blocks.
  * **More Complex:** Requires a stronger understanding of Groovy programming.
  * **No Pre-Validation:** Syntax errors might only be caught when the relevant line of code is executed, leading to failures mid-pipeline.
  * **Less Opinionated:** You have more freedom in structuring your pipeline, which can lead to less consistent or harder-to-read pipelines if not managed well.

**Basic Structure:**

A Scripted Pipeline typically starts with a `node` block (though not strictly mandatory for the entire pipeline, it's highly recommended for creating a workspace). Stages are defined using Groovy closures.

```groovy
// Jenkinsfile (Scripted Syntax)

// 1. node: Specifies the Jenkins agent/node to run the pipeline on and allocates a workspace.
// 'node' is a fundamental step in Scripted Pipeline.
node('my-linux-agent') { // Can specify a label, or 'any' if not specific
    // 2. stage: Defines a logical stage. These are optional in Scripted Pipeline but
    // highly recommended for visualization in Jenkins UI (Stage View).
    stage('Checkout Code') {
        // Steps directly within the stage block (no 'steps' block needed)
        echo "Checking out source code..."
        // Use standard SCM steps provided by Jenkins
        git url: 'https://github.com/your-org/my-project.git', branch: 'main'
    }

    stage('Build') {
        echo "Building the application..."
        // Execute shell commands directly
        sh 'mvn clean install -DskipTests'
    }

    stage('Test') {
        echo "Running tests..."
        // More complex Groovy logic can be used here
        def testResult = sh(script: 'mvn test', returnStatus: true) // Captures exit status
        if (testResult != 0) {
            echo "Tests failed! Aborting."
            currentBuild.result = 'FAILURE' // Set build status
            error("Tests failed!") // Fail the pipeline
        } else {
            echo "Tests passed."
        }
    }

    // Parallel execution is common in Scripted Pipeline
    stage('Parallel Tests') {
        parallel (
            'Unit Tests': {
                echo 'Running unit tests in parallel...'
                sh 'mvn test -Dgroups=unit'
            },
            'Integration Tests': {
                echo 'Running integration tests in parallel...'
                sh 'mvn test -Dgroups=integration'
            }
        )
    }

    stage('Deploy') {
        // Conditional logic based on branch or other factors
        if (env.BRANCH_NAME == 'main') {
            echo "Deploying to production..."
            // You can use 'withCredentials' here just like Declarative
            // withCredentials([usernamePassword(credentialsId: 'my-deploy-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            //     sh "sshpass -p ${PASS} scp -r target/*.jar ${USER}@prod-server:/opt/app/"
            // }
        } else {
            echo "Not deploying from ${env.BRANCH_NAME} to production."
        }
    }

    // Post-build actions can be handled with Groovy's try-catch-finally or 'currentBuild.result'
    try {
        // This 'try' block could wrap the whole pipeline or specific parts
        // All stages would go here
    } catch (Exception e) {
        echo "Pipeline failed due to: ${e.getMessage()}"
        currentBuild.result = 'FAILURE'
        // mail to: 'ops@example.com', subject: 'Scripted Pipeline Failure'
    } finally {
        echo 'Cleaning up workspace...'
        deleteDir() // Cleans the current workspace directory
    }
}
```

### 3\. Key Differences and When to Use Which

| Feature          | Declarative Pipeline                                | Scripted Pipeline                                         |
| :--------------- | :-------------------------------------------------- | :-------------------------------------------------------- |
| **Syntax** | Highly structured, opinionated DSL.                 | Flexible, imperative Groovy script.                       |
| **Readability** | Generally easier to read and understand.            | Can be harder to read for complex logic.                  |
| **Flexibility** | Limited to predefined directives and blocks.        | Full programmatic control; supports any Groovy code.      |
| **Learning Curve** | Lower for basic CI/CD flows.                        | Higher; requires Groovy knowledge.                        |
| **Error Handling** | Uses `post` directives for global/stage status.     | Uses standard Groovy `try/catch/finally` blocks.          |
| **Validation** | Syntax errors detected early (before execution).    | Errors typically found at runtime when the line is executed. |
| **Common Use** | Standard CI/CD workflows (build, test, deploy).     | Complex, dynamic, or highly customized workflows.         |
| **Structure** | Root `pipeline {}` block, strict nesting.           | Root `node {}` block (recommended), free-form Groovy.     |
| **Features** | Directives like `when`, `environment`, `parameters`, `options`, `tools`. | Managed programmatically or via specific steps/plugins.   |

**When to Choose:**

  * **Choose Declarative Pipeline if:**

      * You need a standardized, readable, and maintainable pipeline.
      * Your CI/CD workflow follows a common build-test-deploy pattern.
      * Your team prefers a simpler, more structured approach to pipeline definition.
      * You want early syntax validation and good visualization in Blue Ocean.
      * This is the recommended choice for most new Jenkins Pipelines.

  * **Choose Scripted Pipeline if:**

      * Your pipeline requires complex programmatic logic (e.g., dynamic stage generation, intricate loops, advanced error recovery based on runtime conditions).
      * You need fine-grained control over execution flow and resource allocation.
      * Your team has strong Groovy development expertise.
      * You are building a **Shared Library**, where reusable, complex logic is encapsulated.

**Hybrid Approach:**

It's common to use a **Declarative Pipeline** for the overall structure and then embed **Scripted Pipeline** logic within a `script` block inside a `steps` block when specific complex logic is required. This offers the best of both worlds: the readability and structure of Declarative with the power of Scripted where needed.

```groovy
// Hybrid Example
pipeline {
    agent any
    stages {
        stage('Complex Logic Stage') {
            steps {
                echo 'Running some complex calculations...'
                script {
                    // This is a Scripted Pipeline block within Declarative
                    def data = [1, 2, 3, 4, 5]
                    def sum = 0
                    for (int i = 0; i < data.size(); i++) {
                        sum += data[i]
                    }
                    echo "The sum is: ${sum}"
                }
            }
        }
    }
}
```

Understanding both syntaxes is crucial for effective Jenkins pipeline development, allowing you to choose the right tool for the job.