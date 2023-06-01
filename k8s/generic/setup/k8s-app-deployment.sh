#!/bin/bash

### Docker Login to hub.docker.com so can pull your app images
docker login

cd frontend; make build
docker tag frontend:latest mmodi/frontend:latest
docker push mmodi/frontend:latest

cd backend; make build
docker tag backend:latest mmodi/backend:latest
docker push mmodi/backend:latest

### Create
kubectl create -f database-pv.yaml
kubectl create -f database-pvc.yaml
kubectl create -f database-deployment.yaml
kubectl create -f database-service.yaml

kubectl create -f backend-env-configmap.yaml
kubectl create -f backend-deployment.yaml
kubectl create -f backend-service.yaml

kubectl create -f frontend-deployment.yaml
kubectl create -f frontend-service.yaml

kubectl create -f ingress.yaml

### Apply
kubectl apply -f database-pv.yaml
kubectl apply -f database-pvc.yaml
kubectl apply -f database-deployment.yaml
kubectl apply -f database-service.yaml

kubectl apply -f backend-env-configmap.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml

kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml

kubectl apply -f ingress.yaml
