# Etoro DevOps Assignment: simple-web Helm Chart

## Assignment Summary
- Deploy the `simple-web` application using a Helm chart to an AKS cluster.
- Add Ingress rule for `/gabriel` and ensure public access.
- Add a KEDA autoscaler to the Helm chart to scale the deployment by CPU and memory metrics, active only between 8:00 AM and 12:00 AM (Asia/Jerusalem timezone).
- Provide a Jenkins pipeline job to deploy or destroy the Helm chart from the GitHub repository.

## Steps Completed


### 1. Helm Chart Overview
The `simple-web` Helm chart is designed to deploy the simple-web application to the AKS Cluster.
It includes the following resources:
- **Deployment:** Runs the application container with configurable image, resources, and probes.
- **Service:** Exposes the application internally within the cluster.
- **Ingress:** Configured for the nginx ingress controller, routes external traffic to the application at the `/gabriel` path.
- **KEDA ScaledObject:** Enables autoscaling of the deployment based on CPU and memory usage, with a cron schedule restricting scaling to 8:00 AM–12:00 AM (Asia/Jerusalem timezone).

### 4. Deployment
- Installed the Helm chart to the `gabriel` namespace:
  ```sh
  helm install simple-web ./simple-web --namespace gabriel
  ```
- Verified pod and service are running:
  ```sh
  kubectl get all -n gabriel
  ```

### 5. Ingress Setup
- Configured Ingress in `values.yaml` to expose the app at `/gabriel` using the nginx ingress controller, with a rewrite annotation to route traffic to the app root (`/`).
- Verified external access at `http://98.64.41.189/gabriel` and confirmed the app responds correctly.

## KEDA Autoscaler Setup & Testing

### How to Check Scaling
- Watch the deployment for replica changes:
  ```sh
  kubectl get deployment simple-web -n gabriel -w
  ```
- Check the HPA created by KEDA:
  ```sh
  kubectl get hpa -n gabriel
  kubectl describe hpa keda-hpa-simple-web-keda -n gabriel
  ```
- Check the KEDA ScaledObject status:
  ```sh
  kubectl describe scaledobject simple-web-keda -n gabriel
  ```

### How to Generate Load (to trigger scaling)
1. Start a load generator pod:
   ```sh
   kubectl run -i --tty load-generator --rm --image=busybox -n gabriel --restart=Never -- /bin/sh
   ```
2. Inside the pod, run:
   ```sh
   while true; do wget -q -O- http://simple-web.gabriel.svc.cluster.local; done
   ```
3. In another terminal, watch the HPA:
   ```sh
   kubectl get hpa -n gabriel -w
   ```
4. Check the replica count:
   ```sh
   kubectl get deployment simple-web -n gabriel
   ```

- If CPU or memory usage exceeds the threshold, you should see the number of replicas increase.
- Scaling will only occur between 8:00 AM and 12:00 AM (Asia/Jerusalem timezone) due to the cron trigger.

## KEDA Autoscaler Scaling Test Results

- After deploying the KEDA ScaledObject and generating load using multiple load-generator pods, the deployment scaled up automatically.
- Example output from HPA:
  ```
  NAME                       REFERENCE               TARGETS                                  MINPODS   MAXPODS   REPLICAS   AGE
  keda-hpa-simple-web-keda   Deployment/simple-web   250m/1 (avg), cpu: 44%/50% + 1 more...   1         10        4          37m
  ```
- This confirms that KEDA is correctly monitoring CPU and memory usage and scaling the deployment as required by the assignment.

## Jenkins Pipeline for Deploy/Destroy

- A Jenkins pipeline is provided to deploy or destroy the Helm chart from the GitHub repository.
- The pipeline supports two options: `deploy` (installs/upgrades the release) and `destroy` (uninstalls the release).
- error handling is implemented for the destroy action: if the release does not exist, the pipeline log will show:

  ```
  Helm release not found, nothing to uninstall.
  ```

## Jenkins Credentials

```
username: gabriel
password: Aa123456
```

---
