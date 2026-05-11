#!/bin/bash

clear

read -p "Enter ZONE: " ZONE

export REGION="${ZONE%-*}"

gcloud compute networks create griffin-dev-vpc \
--subnet-mode custom

gcloud compute networks subnets create griffin-dev-wp \
--network=griffin-dev-vpc \
--region $REGION \
--range=192.168.16.0/20

gcloud compute networks subnets create griffin-dev-mgmt \
--network=griffin-dev-vpc \
--region $REGION \
--range=192.168.32.0/20

gsutil cp -r gs://cloud-training/gsp321/dm .

cd dm

sed -i s/SET_REGION/$REGION/g prod-network.yaml

gcloud deployment-manager deployments create prod-network \
--config=prod-network.yaml

cd ..

gcloud compute instances create bastion \
--network-interface=network=griffin-dev-vpc,subnet=griffin-dev-mgmt \
--network-interface=network=griffin-prod-vpc,subnet=griffin-prod-mgmt \
--tags=ssh \
--zone=$ZONE

gcloud compute firewall-rules create fw-ssh-dev \
--source-ranges=0.0.0.0/0 \
--target-tags=ssh \
--allow=tcp:22 \
--network=griffin-dev-vpc

gcloud compute firewall-rules create fw-ssh-prod \
--source-ranges=0.0.0.0/0 \
--target-tags=ssh \
--allow=tcp:22 \
--network=griffin-prod-vpc

gcloud sql instances create griffin-dev-db \
--database-version=MYSQL_5_7 \
--region=$REGION \
--root-password=awesome

gcloud sql databases create wordpress \
--instance=griffin-dev-db

gcloud sql users create wp_user \
--instance=griffin-dev-db \
--password=stormwind_rules

gcloud container clusters create griffin-dev \
--network griffin-dev-vpc \
--subnetwork griffin-dev-wp \
--machine-type e2-standard-4 \
--num-nodes 2 \
--zone $ZONE

gcloud container clusters get-credentials griffin-dev \
--zone $ZONE

cd ~/

gsutil cp -r gs://cloud-training/gsp321/wp-k8s .

cat > wp-k8s/wp-env.yaml <<EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: wordpress-volumeclaim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
---
apiVersion: v1
kind: Secret
metadata:
  name: database
type: Opaque
stringData:
  username: wp_user
  password: stormwind_rules
EOF

cd wp-k8s

kubectl create -f wp-env.yaml

gcloud iam service-accounts keys create key.json \
--iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com

kubectl create secret generic cloudsql-instance-credentials \
--from-file key.json

INSTANCE_ID=$(gcloud sql instances describe griffin-dev-db \
--format='value(connectionName)')

cat > wp-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wordpress
  template:
    metadata:
      labels:
        app: wordpress
    spec:
      containers:
      - image: wordpress
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: 127.0.0.1:3306
        - name: WORDPRESS_DB_USER
          valueFrom:
            secretKeyRef:
              name: database
              key: username
        - name: WORDPRESS_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: database
              key: password
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html

      - name: cloudsql-proxy
        image: gcr.io/cloudsql-docker/gce-proxy:1.33.2
        command:
        - "/cloud_sql_proxy"
        - "-instances=$INSTANCE_ID=tcp:3306"
        - "-credential_file=/secrets/cloudsql/key.json"

        securityContext:
          runAsUser: 2
          allowPrivilegeEscalation: false

        volumeMounts:
        - name: cloudsql-instance-credentials
          mountPath: /secrets/cloudsql
          readOnly: true

      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wordpress-volumeclaim

      - name: cloudsql-instance-credentials
        secret:
          secretName: cloudsql-instance-credentials
EOF

kubectl create -f wp-deployment.yaml
kubectl create -f wp-service.yaml

echo ""
echo "Task 8 (Manual Step)"
echo "Enable Monitoring and create Uptime Check:"
echo "Title: Wordpress Uptime"
echo "Path: /"

echo ""
echo "Get Wordpress External IP:"
kubectl get svc

echo ""
echo "Lab Completed Successfully"
