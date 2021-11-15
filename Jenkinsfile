apiVersion: apps/v1
kind: Deployment
metadata:
  name: cfrontend-app
  labels:
    app: rapdev
#  namespace: rapdev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rapdev
  template:
    metadata:
      labels:
        app: rapdev
    spec:
      containers:
        - name: cfrontend-app
          image: vinaysj/frontend-app
          ports:
            - containerPort: 5000
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
#    namespace: rapdev
    labels:
        app: rapdev
    name: cfrontend-app
spec:
    ports:
        - name: cfrontend-app
          port: 5000
          targetPort: 5000
    selector:
        app: rapdev
    type: NodePort
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cfrontend-app
#  namespace: rapdev
spec:
  rules:
#    - host: frontendapp.rapdev.local
    - http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: cfrontend-app
                port:
                  number: 8080
status: {}
