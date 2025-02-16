#!/bin/bash

# Name of the CSV file
CSV_FILE="external_ips.csv"

# Row 1 of the CSV
echo "name,address,addressType,creationTimestamp,ipVersion,networkTier,status" > $CSV_FILE

ORG_IDS=("ID OF THE ORGANIZATION OR FOLDER ID")
type=("EXTERNAL") # TYPE OF IP THAT YOU WANT TO SEARCH

for ORG_ID in "${ORG_IDS[@]}"
do
    echo "Organization or folder: $ORG_ID"
    for PROJECT_ID in $(gcloud projects list --format="value(projectId)" --filter="parent.id=$ORG_ID") # List all the project
    do
        echo "  Project ID: $PROJECT_ID"
        ip_address=$(gcloud compute addresses list --project=$PROJECT_ID  --format="value(name)" --filter="addressType=$type") #List the external IP address with the gcloud command
        validate_ext_ip=$(gcloud compute addresses list --project=$PROJECT_ID  --format="value(name)" --filter="addressType=$type" | wc -l) # Word count to know if in the project we have a some external IP address

        #Validate if We have a External IP
        if [[ $validate_ext_ip -eq 0 ]]; then   
            echo "No RESERVED IP address or the user does not have permission to list the IP address in this project"  
        else
            # All the values is fill in the CSV file
            gcloud compute addresses list --project=$PROJECT_ID  --format="csv(name,address,addressType,creationTimestamp,ipVersion,networkTier,status)" --filter="addressType=$type" >> $CSV_FILE
        fi
    done
done

echo "ALL YOUR DATA IS IN $CSV_FILE"
