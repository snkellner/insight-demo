#/bin/bash

# Get AWS Working Environments
ALL_INSTANCES=`terraform show -json terraform.tfstate | jq '.values.root_module'`

#AWS_INSTANCES=`echo $ALL_INSTANCES | jq 'select(.address|startswith("netapp-cloudmanager_cvo_aws"))'`

CLIENT_WE_LIST=`echo $ALL_INSTANCES | jq -r '.resources[] | select(.address|startswith("netapp-cloudmanager_cvo")) | "\(.values.id),\(.values.client_id)"'`

# Get refresh token from variables.tf
CC_REFRESH_TOKEN=`grep -A 2 "refresh_token" variables.tf | grep "default" | awk -F'"' '{print $2}'`

# Get Bearer Token
CC_TOKEN="Bearer `curl -s https://netapp-cloud-account.auth0.com/oauth/token --header 'Content-Type:application/json' --data '{"grant_type":"refresh_token", "refresh_token": "'"${CC_REFRESH_TOKEN}"'", "client_id": "Mu0V1ywgYteI6w1MbD15fKfVIUrNXGWC"}' | jq -r .access_token`"

# Create file to output
echo ">>>TERRAFORM OUTPUTS<<<" > './TF_OUTPUTS.txt'

# Iterate through list and pull we info
for i in $CLIENT_WE_LIST
do
  WE="${i%%,*}"
  CLIENT="${i#*,}"
  RESPONSE=`curl -s https://cloudmanager.cloud.netapp.com/occm/api/working-environments/$WE?fields=ontapClusterProperties --header "Content-Type:application/json" --header "Authorization:${CC_TOKEN}" --header "X-Agent-Id:${CLIENT}clients"`
  echo "====================================" >> './TF_OUTPUTS.txt'
  echo "id:" `echo $RESPONSE | jq -r '.publicId'` >> './TF_OUTPUTS.txt'
  echo "name:" `echo $RESPONSE | jq -r '.name'` >> './TF_OUTPUTS.txt'
  echo "clust_mgmt_ip:" `echo $RESPONSE | jq -r '.ontapClusterProperties.nodes[0].lifs[] | select(.lifType == "Cluster Management").ip'` >> './TF_OUTPUTS.txt'
  echo "intercluster_ip:" `echo $RESPONSE | jq -r '.ontapClusterProperties.nodes[0].lifs[] | select(.lifType == "Intercluster").ip'` >> './TF_OUTPUTS.txt'
done

echo "====================================" >> './TF_OUTPUTS.txt'
