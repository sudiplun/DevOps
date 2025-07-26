# NGINX on Kubernetes

This directory contains Kubernetes manifests to deploy an NGINX web server and expose it using a Service and an Ingress.

## Components

- `nginx-deployment.yml`: This file contains the definitions for:
    - A `Deployment` to run a single replica of the NGINX server.
    - A `Service` (`nginx-service`) of type ClusterIP that exposes the NGINX deployment within the cluster on port 8080.
- `ingress.yml`: This file contains the `Ingress` resource definition to expose the `nginx-service` to the outside world at the hostname `nginx.example.com`.

## Prerequisites

- A running Kubernetes cluster.
- `kubectl` configured to communicate with your cluster.
- An Ingress controller (like NGINX Ingress Controller) installed in your cluster.

## Deployment

1.  **Apply the deployment and service:**
    ```bash
    kubectl apply -f nginx-deployment.yml
    ```

2.  **Apply the Ingress:**
    Before applying the Ingress manifest, you might need to edit `ingress.yml` and change `host: "nginx.example.com"` to a domain that points to your Ingress controller's external IP.

    ```bash
    kubectl apply -f ingress.yml
    ```

## Verification

1.  **Check the deployment, service, and pods:**
    ```bash
    kubectl get deployment nginx-deployment
    kubectl get service nginx-service
    kubectl get pods -l app=nginx
    kubectl get ingress nginx-ingress
    ```

2.  **Accessing the NGINX server:**
    Once the Ingress is set up and your DNS is configured, you should be able to access the NGINX default page by navigating to `http://nginx.example.com` in your browser.

    If you are running this locally (e.g., with Minikube or Kind) and don't have DNS configured, you can find the IP of your ingress controller and add an entry to your `/etc/hosts` file:
    ```
    <ingress-controller-ip> nginx.example.com
    ```

## Cleanup

To remove the resources created in this example, run the following commands:

```bash
kubectl delete -f ingress.yml
kubectl delete -f nginx-deployment.yml
```
