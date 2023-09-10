export LOCATION=us
export PROCESSOR_ID=63002b277285c2be



export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value core/project)

gcloud iam service-accounts create my-docai-sa \
  --display-name "my-docai-service-account"

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/documentai.admin"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/storage.admin"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/serviceusage.serviceUsageConsumer"

sleep 20

gcloud iam service-accounts keys create ~/key.json \
  --iam-account  my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS=$(realpath key.json)

pip3 install --upgrade google-cloud-documentai
pip3 install --upgrade google-cloud-storage

sleep 20

gcloud storage cp gs://cloud-samples-data/documentai/codelabs/ocr/Winnie_the_Pooh_3_Pages.pdf .

sleep 20



export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value core/project)
    gcloud iam service-accounts create my-docai-sa \
  --display-name "my-docai-service-account"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/documentai.admin"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/storage.admin"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/serviceusage.serviceUsageConsumer"
    gcloud iam service-accounts keys create ~/key.json \
  --iam-account  my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
  export GOOGLE_APPLICATION_CREDENTIALS=$(realpath key.json)
  pip3 install --upgrade google-cloud-documentai
pip3 install --upgrade google-cloud-storage
gcloud storage cp gs://cloud-samples-data/documentai/codelabs/ocr/Winnie_the_Pooh_3_Pages.pdf .
gcloud storage buckets create gs://$GOOGLE_CLOUD_PROJECT
gcloud storage cp gs://cloud-samples-data/documentai/codelabs/ocr/Winnie_the_Pooh.pdf gs://$GOOGLE_CLOUD_PROJECT/
hustler=$(curl -X GET \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    "https://us-documentai.googleapis.com/v1/projects/$DEVSHELL_PROJECT_ID/locations/us/processors" | jq -r '.processors[] | .name' | awk -F/ '{print $NF}'
)
CLOUDHUS="gs://$DEVSHELL_PROJECT_ID"
echo '
import re
from typing import List
from google.api_core.client_options import ClientOptions
from google.cloud import documentai_v1 as documentai
from google.cloud import storage
PROJECT_ID = "'$DEVSHELL_PROJECT_ID'"
LOCATION = "us"  # Format is 'us' or 'eu'
PROCESSOR_ID = "'$hustler'"  # Create processor in Cloud Console
GCS_INPUT_URI = "gs://cloud-samples-data/documentai/codelabs/ocr/Winnie_the_Pooh.pdf"
INPUT_MIME_TYPE = "application/pdf"
GCS_OUTPUT_URI = "'$CLOUDHUS'"
docai_client = documentai.DocumentProcessorServiceClient(
    client_options=ClientOptions(api_endpoint=f"{LOCATION}-documentai.googleapis.com")
)
RESOURCE_NAME = docai_client.processor_path(PROJECT_ID, LOCATION, PROCESSOR_ID)
input_document = documentai.GcsDocument(
    gcs_uri=GCS_INPUT_URI, mime_type=INPUT_MIME_TYPE
)
input_config = documentai.BatchDocumentsInputConfig(
    gcs_documents=documentai.GcsDocuments(documents=[input_document])
)
gcs_output_config = documentai.DocumentOutputConfig.GcsOutputConfig(
    gcs_uri=GCS_OUTPUT_URI
)
output_config = documentai.DocumentOutputConfig(gcs_output_config=gcs_output_config)
request = documentai.BatchProcessRequest(
    name=RESOURCE_NAME,
    input_documents=input_config,
    document_output_config=output_config,
)
operation = docai_client.batch_process_documents(request)
print(f"Waiting for operation {operation.operation.name} to complete...")
operation.result()
print("Document processing complete.")
metadata = documentai.BatchProcessMetadata(operation.metadata)
if metadata.state != documentai.BatchProcessMetadata.State.SUCCEEDED:
    raise ValueError(f"Batch Process Failed: {metadata.state_message}")
documents: List[documentai.Document] = []
storage_client = storage.Client()
for process in metadata.individual_process_statuses:
    output_bucket, output_prefix = re.match(
        r"gs://(.*?)/(.*)", process.output_gcs_destination
    ).groups()
    output_blobs = storage_client.list_blobs(output_bucket, prefix=output_prefix)
    for blob in output_blobs:
        if ".json" not in blob.name:
            print(f"Skipping non-supported file type {blob.name}")
            continue
        print(f"Fetching {blob.name}")
        document = documentai.Document.from_json(
            blob.download_as_bytes(), ignore_unknown_fields=True
        )
        documents.append(document)
for document in documents:
    print(document.text[:100])
' > batch_processing.py





python3 batch_processing.py






gcloud storage cp --recursive gs://cloud-samples-data/documentai/codelabs/ocr/multi-document gs://$GOOGLE_CLOUD_PROJECT/
echo '
import re
from typing import List
from google.api_core.client_options import ClientOptions
from google.cloud import documentai_v1 as documentai
from google.cloud import storage
PROJECT_ID = "'$DEVSHELL_PROJECT_ID'"
LOCATION = "us"  # Format is 'us' or 'eu'
PROCESSOR_ID = "'$hustler'"  
GCS_INPUT_PREFIX = "gs://cloud-samples-data/documentai/codelabs/ocr/multi-document"
GCS_OUTPUT_URI = "'$CLOUDHUS'"
docai_client = documentai.DocumentProcessorServiceClient(
    client_options=ClientOptions(api_endpoint=f"{LOCATION}-documentai.googleapis.com")
)
RESOURCE_NAME = docai_client.processor_path(PROJECT_ID, LOCATION, PROCESSOR_ID)
gcs_prefix = documentai.GcsPrefix(gcs_uri_prefix=GCS_INPUT_PREFIX)
input_config = documentai.BatchDocumentsInputConfig(gcs_prefix=gcs_prefix)
gcs_output_config = documentai.DocumentOutputConfig.GcsOutputConfig(
    gcs_uri=GCS_OUTPUT_URI
)
output_config = documentai.DocumentOutputConfig(gcs_output_config=gcs_output_config)
request = documentai.BatchProcessRequest(
    name=RESOURCE_NAME,
    input_documents=input_config,
    document_output_config=output_config,
)
operation = docai_client.batch_process_documents(request)
print(f"Waiting for operation {operation.operation.name} to complete...")
operation.result()
print("Document processing complete.")
metadata = documentai.BatchProcessMetadata(operation.metadata)
if metadata.state != documentai.BatchProcessMetadata.State.SUCCEEDED:
    raise ValueError(f"Batch Process Failed: {metadata.state_message}")
documents: List[documentai.Document] = []
storage_client = storage.Client()
for process in metadata.individual_process_statuses:
    output_bucket, output_prefix = re.match(
        r"gs://(.*?)/(.*)", process.output_gcs_destination
    ).groups()
    output_blobs = storage_client.list_blobs(output_bucket, prefix=output_prefix)
    for blob in output_blobs:
        if ".json" not in blob.name:
            print(f"Skipping non-supported file type {blob.name}")
            continue
        print(f"Fetching {blob.name}")
        document = documentai.Document.from_json(
            blob.download_as_bytes(), ignore_unknown_fields=True
        )
        documents.append(document)
for document in documents:
    print(document.text[:100])
' > batch_processing_directory.py





python3 batch_processing_directory.py
