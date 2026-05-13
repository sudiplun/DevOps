# Homelab - Nextcloud with PostgreSQL

This setup deploys a Nextcloud instance with a PostgreSQL database using Docker Compose.

## Prerequisites

- Docker
- Docker Compose

## Setup

1.  **Create the Docker Network:**
    This setup requires a pre-existing external Docker network.

    ```bash
    docker network create homelab
    ```

2.  **Configure Environment Variables:**
    Create a `.env` file from the sample and fill in the required values.

    ```bash
    cp .env.sample .env
    ```

    You will need to set the following variables in the `.env` file:
    - `password`: The password for the PostgreSQL database.
    - `pg_db_name`: The name of the PostgreSQL database.
    - `pg_username`: The username for the PostgreSQL database.

## Usage

1.  **Start the services:**

    ```bash
    docker compose up -d
    ```

2.  **Access Nextcloud:**
    Once the containers are running, you can access Nextcloud in your browser at `http://localhost:5174`.

3.  **Stop the services:**

    ```bash
    docker compose down
    ```

## Services

-   **`nc`**: The Nextcloud application.
-   **`db`**: The PostgreSQL database.

## Volumes

-   `nc_data`: Persists Nextcloud data.
-   `nc_db_data`: Persists PostgreSQL data.
