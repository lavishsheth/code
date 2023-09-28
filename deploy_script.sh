#!/bin/bash

# Clone the repository
git clone https://github.com/rosera/pet-theory.git
cd pet-theory/lab03

# Create package.json and install dependencies
cat > package.json <<EOF_END
{
  "name": "lab03",
  "version": "1.0.0",
  "description": "This is lab03 of the Pet Theory labs",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "Patrick - IT",
  "license": "MIT"
}
EOF_END
npm install express body-parser child_process @google-cloud/storage

# Submit the Docker image to Google Cloud Build
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/pdf-converter

# Deploy the service to Google Cloud Run
gcloud run deploy pdf-converter \
  --image gcr.io/$DEVSHELL_PROJECT_ID/pdf-converter \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --max-instances=1

# Create Storage Buckets
gsutil mb gs://$DEVSHELL_PROJECT_ID-upload
gsutil mb gs://$DEVSHELL_PROJECT_ID-processed

# Enable Pub/Sub and set up IAM permissions
gcloud services enable pubsub.googleapis.com --project=$DEVSHELL_PROJECT_ID
gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker"

export PROJECT_NUMBER=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format="value(projectNumber)")

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com --role=roles/iam.serviceAccountTokenCreator

gcloud beta run services add-iam-policy-binding pdf-converter --member=serviceAccount:pubsub-cloud-run-invoker@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --role=roles/run.invoker --platform managed --region $REGION

# Create Pub/Sub Subscription
SERVICE_URL=$(gcloud beta run services describe pdf-converter --platform managed --region $REGION --format="value(status.url)")

gcloud beta pubsub subscriptions create pdf-conv-sub --topic new-doc --push-endpoint=$SERVICE_URL --push-auth-service-account=pubsub-cloud-run-invoker@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

# Upload sample data to the Storage Bucket
gsutil -m cp gs://spls/gsp644/* gs://$DEVSHELL_PROJECT_ID-upload
gsutil -m rm gs://$DEVSHELL_PROJECT_ID-upload/*

# Create Dockerfile and update the Docker image
cat > Dockerfile <<EOF_END
FROM node:16
RUN apt-get update -y \
    && apt-get install -y libreoffice \
    && apt-get clean
WORKDIR /usr/src/app
COPY package.json package*.json ./
RUN npm install --only=production
COPY . .
EXPOSE 8080
CMD [ "npm", "start" ]
EOF_END

gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/pdf-converter

# Deploy the updated service to Google Cloud Run
gcloud run deploy pdf-converter \
  --image gcr.io/$DEVSHELL_PROJECT_ID/pdf-converter \
  --platform managed \
  --region $REGION \
  --memory=2Gi \
  --no-allow-unauthenticated \
  --max-instances=1 \
  --set-env-vars PDF_BUCKET=$DEVSHELL_PROJECT_ID-processed
