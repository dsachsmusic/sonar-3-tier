### start minikube
minikube start

### Use Kubectl to apply the yaml files
- `kubectl apply -f c:\users\david\working\sonar-3-tier\local_dev_setup\k8s\configmaps\frontend-configmap.yaml`
- `kubectl apply -f c:\users\david\working\sonar-3-tier\local_dev_setup\k8s\configmaps\inventory-configmap.yaml`
- `kubectl apply -f c:\users\david\working\sonar-3-tier\local_dev_setup\k8s\configmaps\orders-configmap.yaml`
- `kubectl apply -f c:\users\david\working\sonar-3-tier\local_dev_setup\k8s\deployments\frontend-deployment.yaml`
- `kubectl apply -f c:\users\david\working\sonar-3-tier\local_dev_setup\k8s\deployments\inventory-deployment.yaml`
- `kubectl apply -f c:\users\david\working\sonar-3-tier\local_dev_setup\k8s\deployments\orders-deployment.yaml`
- `kubectl apply -f c:\users\david\working\sonar-3-tier\local_dev_setup\k8s\services\frontend-service.yaml`
- `kubectl apply -f c:\users\david\working\sonar-3-tier\local_dev_setup\k8s\services\inventory-service.yaml`
- `kubectl apply -f c:\users\david\working\sonar-3-tier\local_dev_setup\k8s\services\orders-service.yaml`
- `kubectl apply -f C:\users\david\working\sonar-3-tier\local_dev_setup\k8s\rbac\api-access-role.yaml`
- `kubectl apply -f C:\users\david\working\sonar-3-tier\local_dev_setup\k8s\rbac\api-access-role-binding.yaml`

### Confirm pods and services are running
- `kubectl get pods`
- `kubectl get deployments`
- `kubectl get services`

Note: `minikube service <service name>` ... URL for connecting to service (via a tunnel created by minikube)

### Test functionality
Use minikube tunnel to connect to services
- `minikube service <servicename>` - for a tunnel to an individual service...
- `minikube tunnel` - creates a tunnel to minikube...all exposed services (?)



Using Postman and/or browser, test functionality...
- issues?  Do some troubleshooting
  - ssh into a pod: `kubectl exec -it <pod-name> -- /bin/bash`
    - `apt-get update`
	  - `apt-get install curl`
	  - `apt-get install -y postgresql-client`
	  - etc
  - look at logs: `kubectl logs <pod name>`
    - note: If your application writes logs to stdout, Kubernetes should expose them to you

### Fix issues
- Changes to a Docker image?  Rebuild, push changes to Docker Hub, then run - kubectl get pods...and...for each, run `kubectl delete pod <podname>`
  - Can also do `kubectl delete pods -l app=orders` and `kubectl delete pods -l app=inventory` in our case, because we used labels

Potential issues:
- Can't connect to DB
  - Is DB_HOST parameter (in Config Map) set to the local host IP?
  - Try setting an exception in C:\Program Files\PostgreSQL\16\data\pg_hba.conf
    ```
	host    all             all             192.168.86.153/32       trust
	```
    - Then, restart the service
	  ```get-service | where name -like "postgres*" | Restart-Service```

  - `apt-get update`
  - `apt-get install -y postgresql-client`
  - `pg_isready -h 192.168.86.153 -p 5432 -U postgres`
  - `psql -h 192.168.86.153 -p 5432 -U postgres -d orders`
  - `select * from orders;`

### Issues with pods spinning up
`kubectl describe deployment orders`
`kubectl rollout status deployment/orders-deployment`

### More troubleshooting tips
Create and shell into a busybox
`kubectl run -i --tty --rm debug --image=busybox --restart=Never -- sh`

### Issues with roles/role bindings
`kubectl auth can-i get deployments --as=system:serviceaccount:default:default`
etc.