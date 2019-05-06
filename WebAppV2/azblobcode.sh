blobStorageAccount=moblobstorage

az storage account create --name $blobStorageAccount --location southcentralus --resource-group project1 --sku Standard_LRS --kind blobstorage --access-tier hot

az storage account create --name $blobStorageAccount \
--location southcentralus --resource-group project1 \
--sku Standard_LRS --kind blobstorage --access-tier hot 

blobStorageAccountKey=$(az storage account keys list -g project1 \
  -n $blobStorageAccount --query [0].value --output tsv)

blobStorageAccountKey pmTf7/FKaaCzPsWVcs4c7cSwsFLr0rvyRFFOjarpE6pwJFulB0bAlhh5UVjmk/lq48bmSP1NfpCio/Fuirtyyg==

az appservice plan create --name myAppServicePlan --resource-group project1 --sku Free

webapp=mowebapp234

az webapp create --name $webapp --resource-group project1 --plan myAppServicePlan

az webapp deployment source config --name $webapp \
--resource-group project1 --branch master --manual-integration \
--repo-url https://github.com/Azure-Samples/storage-blob-upload-from-webapp-node-v10

# ------------------------------------------------- to create blob storage

az group create --name myResourceGroup --location southcentralus
blobStorageAccount=moblobstorage4

az storage account create --name $blobStorageAccount \
--location southcentralus --resource-group myResourceGroup \
--sku Standard_LRS --kind blobstorage --access-tier hot  

blobStorageAccountKey=$(az storage account keys list -g myResourceGroup \
-n $blobStorageAccount --query [0].value --output tsv)

az storage container create -n images --account-name $blobStorageAccount \
--account-key $blobStorageAccountKey --public-access off

az storage container create -n thumbnails --account-name $blobStorageAccount \
--account-key $blobStorageAccountKey --public-access container

echo "Make a note of your Blob storage account key..."
echo $blobStorageAccountKey

# make sure its linux
az appservice plan create --name myAppServicePlan --resource-group myResourceGroup --sku B1 --is-linux

# get most recent node
webapp=mowebapp234

az webapp create --name $webapp --resource-group myResourceGroup --plan myAppServicePlan --runtime "NODE|10.14"

az webapp deployment source config --name $webapp \
--resource-group myResourceGroup --branch master --manual-integration \
--repo-url https://github.com/Azure-Samples/storage-blob-upload-from-webapp-node

storageConnectionString=$(az storage account show-connection-string --resource-group myResourceGroup \
--name $blobStorageAccount --query connectionString --output tsv)

az webapp config appsettings set --name $webapp --resource-group myResourceGroup \
--settings AzureStorageConfig__ImageContainer=images  \
AzureStorageConfig__ThumbnailContainer=thumbnails \
AzureStorageConfig__AccountName=$blobStorageAccount \
AzureStorageConfig__AccountKey=$blobStorageAccountKey \
AZURE_STORAGE_CONNECTION_STRING=$storageConnectionString

# ------------------------------ creating servers
az appservice plan create --name myPlan --resource-group myResourceGroup --is-linux --location southcentralus --number-of-workers 3 --sku B1

# ------------------------------ using the thumbnail faas

# azure storage account

resourceGroupName=myResourceGroup

functionstorage=mofunstorage

az storage account create --name $functionstorage --location southeastasia \
--resource-group $resourceGroupName --sku Standard_LRS --kind storage

# function app

functionapp=mofunapp

az functionapp create --name $functionapp --storage-account $functionstorage \
--resource-group $resourceGroupName --consumption-plan-location southeastasia

# configure function app

blobStorageAccount=moblobstorage4

storageConnectionString=$(az storage account show-connection-string --resource-group $resourceGroupName \
--name $blobStorageAccount --query connectionString --output tsv)

az functionapp config appsettings set --name $functionapp --resource-group $resourceGroupName \
--settings AZURE_STORAGE_CONNECTION_STRING=$storageConnectionString \
THUMBNAIL_WIDTH=100 FUNCTIONS_EXTENSION_VERSION=~2

# deploy the function code

az functionapp deployment source config --name $functionapp \
--resource-group $resourceGroupName --branch master --manual-integration \
--repo-url https://github.com/Azure-Samples/storage-blob-resize-function-node