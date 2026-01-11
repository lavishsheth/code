#!/bin/bash

# List active authentication
gcloud auth list

# Retrieve default region from project metadata
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Retrieve project ID and project number
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')

# Enable necessary APIs
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Create directory for HTTP function
mkdir -p ~/hello-go-http && cd ~/hello-go-http

# Create main.go for HTTP function
cat > main.go <<EOF
package function

import (
    "fmt"
    "net/http"
)

// HelloGo is the entry point for HTTP
func HelloGo(w http.ResponseWriter, r *http.Request) {
    fmt.Fprint(w, "Hello from Cloud Functions (Go 2nd Gen)!")
}
EOF

# Create go.mod
cat > go.mod <<EOF
module example.com/hellogo

go 1.22
EOF

# Deploy HTTP-triggered function
gcloud functions deploy cf-go \
  --gen2 \
  --region=${REGION} \
  --runtime=go122 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point=HelloGo \
  --min-instances=5 \
  --source=.

# Create directory for Pub/Sub function
mkdir -p ~/hello-go-pubsub && cd ~/hello-go-pubsub

# Create main.go for Pub/Sub function
cat > main.go <<EOF
package function

import (
	"context"
	"log"
)

type PubSubMessage struct {
	Data []byte \`json:"data"\`
}

func HelloPubSub(ctx context.Context, m PubSubMessage) error {
	name := string(m.Data)
	if name == "" {
		name = "World"
	}
	log.Printf("Hello, %s!", name)
	return nil
}
EOF

# Create go.mod
cat > go.mod <<EOF
module example.com/hellogo

go 1.22
EOF

# Grant necessary role to Pub/Sub service account
PUBSUB_SA="service-${PROJECT_NUMBER}@gcp-sa-pubsub.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${PUBSUB_SA}" \
  --role="roles/iam.serviceAccountTokenCreator"

# Deploy Pub/Sub-triggered function, answering 'n' to any prompts
echo "n" | gcloud functions deploy cf-pubsub \
  --gen2 \
  --region=${REGION} \
  --runtime=go122 \
  --trigger-topic=cf-pubsub \
  --entry-point=HelloPubSub \
  --min-instances=5 \
  --source=.
