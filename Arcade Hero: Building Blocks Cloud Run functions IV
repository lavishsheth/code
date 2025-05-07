#!/bin/bash

export PROJECT_ID=$(gcloud config get-value project)
export REGION="change region"
export FUNCTION_NAME="name"

mkdir -p cloud-function
cat > cloud-function/index.js <<EOF
exports.helloWorld = (req, res) => {
  res.send('Hello from Cloud Function!');
};
EOF

cat > cloud-function/package.json <<EOF
{
  "name": "cf-nodejs",
  "version": "1.0.0",
  "main": "index.js"
}
EOF

gcloud functions deploy ${FUNCTION_NAME} \
  --gen2 \
  --runtime=nodejs20 \
  --region=${REGION} \
  --source=cloud-function \
  --entry-point=helloWorld \
  --trigger-http \
  --max-instances=5 \
  --allow-unauthenticated

cd ~
for file in *; do
  if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
    if [[ -f "$file" ]]; then
      rm "$file"
    fi
  fi
done
