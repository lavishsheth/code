#!/bin/bash

# Step 1: Create redact-request.json
cat > redact-request.json <<EOF_END
{
	"item": {
		"value": "Please update my records with the following information:\n Email address: foo@example.com,\nNational Provider Identifier: 1245319599"
	},
	"deidentifyConfig": {
		"infoTypeTransformations": {
			"transformations": [{
				"primitiveTransformation": {
					"replaceWithInfoTypeConfig": {}
				}
			}]
		}
	},
	"inspectConfig": {
		"infoTypes": [{
				"name": "EMAIL_ADDRESS"
			},
			{
				"name": "US_HEALTHCARE_NPI"
			}
		]
	}
}
EOF_END

# Step 2: Deidentify content using DLP API
curl -s \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/content:deidentify \
  -d @redact-request.json -o redact-response.txt

# Step 3: Upload result to Cloud Storage
gsutil cp redact-response.txt gs://$DEVSHELL_PROJECT_ID-redact

# Step 4: Create structured data template
cat <<EOF > template.json
{
  "deidentifyTemplate": {
    "deidentifyConfig": {
      "recordTransformations": {
        "fieldTransformations": [
          {
            "fields": [
              { "name": "bank name" },
              { "name": "zip code" }
            ],
            "primitiveTransformation": {
              "characterMaskConfig": {
                "maskingCharacter": "#"
              }
            }
          },
          {
            "fields": [
              { "name": "message" }
            ],
            "infoTypeTransformations": {
              "transformations": [
                {
                  "primitiveTransformation": {
                    "replaceWithInfoTypeConfig": {}
                  }
                }
              ]
            }
          }
        ]
      }
    },
    "displayName": "structured_data_template"
  },
  "locationId": "us",
  "templateId": "structured_data_template"
}
EOF

# Step 5: Upload structured template to DLP
curl -X POST -s \
-H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
-H "Content-Type: application/json" \
-d @template.json \
"https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/locations/us/deidentifyTemplates"

# Step 6: Create unstructured data template
cat > template.json <<'EOF_END'
{
  "deidentifyTemplate": {
    "deidentifyConfig": {
      "infoTypeTransformations": {
        "transformations": [
          {
            "primitiveTransformation": {
              "replaceConfig": {
                "newValue": {
                  "stringValue": "[redacted]"
                }
              }
            }
          }
        ]
      }
    },
    "displayName": "unstructured_data_template"
  },
  "templateId": "unstructured_data_template"
}
EOF_END

# Step 7: Upload unstructured template to DLP
curl -X POST -s \
-H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
-H "Content-Type: application/json" \
-d @template.json \
"https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/locations/us/deidentifyTemplates"

# Step 8: Create job-configuration.json
cat > job-configuration.json << EOM
{
  "triggerId": "dlp_job",
  "jobTrigger": {
    "triggers": [
      {
        "schedule": {
          "recurrencePeriodDuration": "604800s"
        }
      }
    ],
    "inspectJob": {
      "actions": [
        {
          "deidentify": {
            "fileTypesToTransform": [
              "TEXT_FILE",
              "IMAGE",
              "CSV",
              "TSV"
            ],
            "transformationDetailsStorageConfig": {},
            "transformationConfig": {
              "deidentifyTemplate": "projects/$DEVSHELL_PROJECT_ID/locations/us/deidentifyTemplates/unstructured_data_template",
              "structuredDeidentifyTemplate": "projects/$DEVSHELL_PROJECT_ID/locations/us/deidentifyTemplates/structured_data_template"
            },
            "cloudStorageOutput": "gs://$DEVSHELL_PROJECT_ID-output"
          }
        }
      ],
      "inspectConfig": {
        "infoTypes": [
          { "name": "ADVERTISING_ID" },
          { "name": "AGE" },
          { "name": "ARGENTINA_DNI_NUMBER" },
          { "name": "AUSTRALIA_TAX_FILE_NUMBER" },
          { "name": "BELGIUM_NATIONAL_ID_CARD_NUMBER" },
          { "name": "BRAZIL_CPF_NUMBER" },
          { "name": "CANADA_SOCIAL_INSURANCE_NUMBER" },
          { "name": "CHILE_CDI_NUMBER" },
          { "name": "CHINA_RESIDENT_ID_NUMBER" },
          { "name": "COLOMBIA_CDC_NUMBER" },
          { "name": "CREDIT_CARD_NUMBER" },
          { "name": "CREDIT_CARD_TRACK_NUMBER" },
          { "name": "DATE_OF_BIRTH" },
          { "name": "DENMARK_CPR_NUMBER" },
          { "name": "EMAIL_ADDRESS" },
          { "name": "ETHNIC_GROUP" },
          { "name": "FDA_CODE" },
          { "name": "FINLAND_NATIONAL_ID_NUMBER" },
          { "name": "FRANCE_CNI" },
          { "name": "FRANCE_NIR" },
          { "name": "FRANCE_TAX_IDENTIFICATION_NUMBER" },
          { "name": "GENDER" },
          { "name": "GERMANY_IDENTITY_CARD_NUMBER" },
          { "name": "GERMANY_TAXPAYER_IDENTIFICATION_NUMBER" },
          { "name": "HONG_KONG_ID_NUMBER" },
          { "name": "IBAN_CODE" },
          { "name": "IMEI_HARDWARE_ID" },
          { "name": "INDIA_AADHAAR_INDIVIDUAL" },
          { "name": "INDIA_GST_INDIVIDUAL" },
          { "name": "INDIA_PAN_INDIVIDUAL" },
          { "name": "INDONESIA_NIK_NUMBER" },
          { "name": "IRELAND_PPSN" },
          { "name": "ISRAEL_IDENTITY_CARD_NUMBER" },
          { "name": "JAPAN_INDIVIDUAL_NUMBER" },
          { "name": "KOREA_RRN" },
          { "name": "MAC_ADDRESS" },
          { "name": "MEXICO_CURP_NUMBER" },
          { "name": "NETHERLANDS_BSN_NUMBER" },
          { "name": "NORWAY_NI_NUMBER" },
          { "name": "PARAGUAY_CIC_NUMBER" },
          { "name": "PASSPORT" },
          { "name": "PERSON_NAME" },
          { "name": "PERU_DNI_NUMBER" },
          { "name": "PHONE_NUMBER" },
          { "name": "POLAND_NATIONAL_ID_NUMBER" },
          { "name": "PORTUGAL_CDC_NUMBER" },
          { "name": "SCOTLAND_COMMUNITY_HEALTH_INDEX_NUMBER" },
          { "name": "SINGAPORE_NATIONAL_REGISTRATION_ID_NUMBER" },
          { "name": "SPAIN_CIF_NUMBER" },
          { "name": "SPAIN_DNI_NUMBER" },
          { "name": "SPAIN_NIE_NUMBER" },
          { "name": "SPAIN_NIF_NUMBER" },
          { "name": "SPAIN_SOCIAL_SECURITY_NUMBER" },
          { "name": "STORAGE_SIGNED_URL" },
          { "name": "STREET_ADDRESS" },
          { "name": "SWEDEN_NATIONAL_ID_NUMBER" },
          { "name": "SWIFT_CODE" },
          { "name": "THAILAND_NATIONAL_ID_NUMBER" },
          { "name": "TURKEY_ID_NUMBER" },
          { "name": "UK_NATIONAL_HEALTH_SERVICE_NUMBER" },
          { "name": "UK_NATIONAL_INSURANCE_NUMBER" },
          { "name": "UK_TAXPAYER_REFERENCE" },
          { "name": "URUGUAY_CDI_NUMBER" },
          { "name": "US_BANK_ROUTING_MICR" },
          { "name": "US_EMPLOYER_IDENTIFICATION_NUMBER" },
          { "name": "US_HEALTHCARE_NPI" },
          { "name": "US_INDIVIDUAL_TAXPAYER_IDENTIFICATION_NUMBER" },
          { "name": "US_SOCIAL_SECURITY_NUMBER" },
          { "name": "VEHICLE_IDENTIFICATION_NUMBER" },
          { "name": "VENEZUELA_CDI_NUMBER" },
          { "name": "WEAK_PASSWORD_HASH" },
          { "name": "AUTH_TOKEN" },
          { "name": "AWS_CREDENTIALS" },
          { "name": "AZURE_AUTH_TOKEN" },
          { "name": "BASIC_AUTH_HEADER" },
          { "name": "ENCRYPTION_KEY" },
          { "name": "GCP_API_KEY" },
          { "name": "GCP_CREDENTIALS" },
          { "name": "JSON_WEB_TOKEN" },
          { "name": "HTTP_COOKIE" },
          { "name": "XSRF_TOKEN" }
        ],
        "minLikelihood": "POSSIBLE"
      },
      "storageConfig": {
        "cloudStorageOptions": {
          "filesLimitPercent": 100,
          "fileTypes": [
            "TEXT_FILE",
            "IMAGE",
            "WORD",
            "PDF",
            "AVRO",
            "CSV",
            "TSV",
            "EXCEL",
            "POWERPOINT"
          ],
          "fileSet": {
            "regexFileSet": {
              "bucketName": "$DEVSHELL_PROJECT_ID-input",
              "includeRegex": [],
              "excludeRegex": []
            }
          }
        }
      }
    },
    "status": "HEALTHY"
  }
}
EOM

# Step 9: Send job configuration to DLP API
curl -s \
-H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
-H "Content-Type: application/json" \
https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/locations/us/jobTriggers \
-d @job-configuration.json

# Step 10: Wait 60 seconds for job trigger to be ready
for ((i=60; i>=0; i--)); do
  sleep 1
done

# Step 11: Activate DLP job trigger
curl --request POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "X-Goog-User-Project: $DEVSHELL_PROJECT_ID" \
  "https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/locations/us/jobTriggers/dlp_job:activate"

cd

remove_files() {
    for file in *; do
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            if [[ -f "$file" ]]; then
                rm "$file"
            fi
        fi
    done
}

remove_files
