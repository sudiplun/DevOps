# Employee Record Management System (ERMS) - Dockerized

This project provides a containerized setup for a PHP-based Employee Record Management System. It uses Docker and Docker Compose to orchestrate the necessary services (PHP/Apache and MariaDB), making it easy to set up, run, and develop locally.

The original PHP source code for the Employee Record Management System can be found [here](https://phpgurukul.com/employee-record-management-system-in-php-and-mysql/).

## Tech Stack

*   **Backend:** PHP
*   **Web Server:** Apache
*   **Database:** MariaDB
*   **Containerization:** Docker, Docker Compose

## Prerequisites

Before you begin, ensure you have the following installed on your system:
*   [Docker](https://docs.docker.com/get-docker/)
*   [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

Follow these steps to get the application up and running.

### 1. Source Code and Database

The application's PHP files and the database dump (`.sql` file) are required.

1.  **Download the source code:** [Download Link](https://phpgurukul.com/wp-content/uploads/2019/02/Employee-Record-Management-System-Project.zip)
2.  **Extract the Zip File:** Unzip the downloaded file into the current project directory.
3.  **Locate the Database Dump:** After extracting, you will find an `erms.sql` file. This file is essential for setting up the database.

### 2. Configuration

The application uses environment variables for configuration.

1.  **Create an environment file:** Copy the example file to a new `.env` file.
    ```bash
    cp .env.example .env
    ```
2.  **Edit the `.env` file:** Open the `.env` file and customize the values as needed.

    | Variable      | Description                                          | Default   |
    |---------------|------------------------------------------------------|-----------|
    | `port`        | The host port to access the web application.         | `8080`    |
    | `hostname`    | The database host (used by the application).         | `mariadb` |
    | `db_name`     | The name of the database.                            | `erms`    |
    | `db_user`     | The username for the database.                       | `admin`   |
    | `db_password` | The password for the database user.                  | `admin`   |

### 3. Network Setup

This setup uses a custom Docker network to facilitate communication between containers.

Create the network using the following command:
```bash
docker network create my-network-erms
```

### 4. Launch the Application

With the configuration in place, you can now launch the application using Docker Compose.

```bash
docker compose up -d
```

This command will build the PHP/Apache image, pull the MariaDB image, and start both containers in the background.

## Usage

Once the containers are running, you can access the Employee Record Management System in your web browser at:

**http://localhost:8980**

*(Note: If you changed the `port` in your `.env` file, use that port instead.)*

## Database Management

*   **Initialization:** The MariaDB container automatically initializes the database on its first run. It imports the data from the `erms.sql` file located in the project root, creating the necessary tables and records.

*   **Backup:** To create a database backup (a `.sql` dump), you can use the `mysqldump` utility. This is useful for persisting data or migrating the database.
    ```bash
    docker compose exec mariadb mysqldump -u<user> -p<password> <database_name> > backup.sql
    ```
    Replace `<user>`, `<password>`, and `<database_name>` with the values from your `.env` file.

## Deployment Insights: Docker vs. Bare Metal

This project demonstrates the power of containerization for simplifying application deployment.

*   **Bare Metal Approach:** A traditional deployment on a bare-metal server would require manual installation and configuration of a web server (like Nginx or Apache), a database server (like MariaDB), and the correct version of PHP with necessary extensions (e.g., `php-fpm`, `php-mysql`). This process can be complex, error-prone, and difficult to replicate consistently across different environments.

*   **Dockerized Approach:** By using Docker, we encapsulate the application and its dependencies into isolated containers. The `docker-compose.yml` file defines the entire stack as code, ensuring a consistent and reproducible environment. This eliminates the "it works on my machine" problem and streamlines the development-to-production workflow.
