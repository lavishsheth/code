gcloud auth list
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
gcloud services enable firestore.googleapis.com
gcloud firestore databases create --location=$REGION --type=firestore-native
