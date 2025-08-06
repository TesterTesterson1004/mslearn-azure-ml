#! /usr/bin/sh

# Check if a suffix was passed as an argument
if [[ -n "$1" ]]; then
  suffix=$1
else
  # Generate random suffix from UUID if none was provided
  guid=$(cat /proc/sys/kernel/random/uuid)
  suffix=${guid//[-]/}
  suffix=${suffix:0:18}
fi

echo "Suffix: $suffix"

# Set the necessary variables
RESOURCE_GROUP="rg-dp100-l${suffix}"
#!/usr/bin/env bash

# Define available regions
REGIONS=("eastus" "westus" "centralus" "northeurope" "westeurope")

echo "Available Azure Regions:"
for i in "${!REGIONS[@]}"; do
  echo "  [$i] ${REGIONS[$i]}"
done

# Prompt user for input
read -p "Enter the number of the region you want to use (or press Enter for random): " choice

# If input is valid, use that region; otherwise, pick randomly
if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 0 && choice < ${#REGIONS[@]} )); then
  SELECTED_REGION=${REGIONS[$choice]}
else
  SELECTED_REGION=${REGIONS[$RANDOM % ${#REGIONS[@]}]}
  echo "No valid selection made. Using random region: $SELECTED_REGION"
fi

# Output selected region
echo "Selected region: $SELECTED_REGION"
WORKSPACE_NAME="mlw-dp100-l${suffix}"
COMPUTE_INSTANCE="ci${suffix}"
COMPUTE_CLUSTER="aml-cluster"

# Register the Azure Machine Learning and additional resource providers in the subscription
echo "Register the required resource providers:"
az provider register --namespace "Microsoft.MachineLearningServices"
az provider register --namespace "Microsoft.PolicyInsights"
az provider register --namespace "Microsoft.Cdn"

# Create the resource group and workspace and set to default
echo "Create a resource group and set as default:"
az group create --name $RESOURCE_GROUP --location $RANDOM_REGION
az configure --defaults group=$RESOURCE_GROUP

echo "Create an Azure Machine Learning workspace:"
az ml workspace create --name $WORKSPACE_NAME 
az configure --defaults workspace=$WORKSPACE_NAME 

# Create compute instance
echo "Creating a compute instance with name: " $COMPUTE_INSTANCE
az ml compute create --name ${COMPUTE_INSTANCE} --size STANDARD_DS11_V2 --type ComputeInstance 

# Create compute cluster
echo "Creating a compute cluster with name: " $COMPUTE_CLUSTER
az ml compute create --name ${COMPUTE_CLUSTER} --size STANDARD_DS11_V2 --max-instances 2 --type AmlCompute 
