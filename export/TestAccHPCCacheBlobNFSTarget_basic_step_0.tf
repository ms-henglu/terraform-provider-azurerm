

provider "azurerm" {
  features {}
}

provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-210825042917549819"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VN-210825042917549819"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsub-210825042917549819"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefix       = "10.0.2.0/24"
  service_endpoints    = ["Microsoft.Storage"]
}

data "azuread_service_principal" "test" {
  display_name = "HPC Cache Resource Provider"
}

resource "azurerm_storage_account" "test" {
  name                      = "accteststorgaccf2ym2"
  resource_group_name       = azurerm_resource_group.test.name
  location                  = azurerm_resource_group.test.location
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  is_hns_enabled            = true
  nfsv3_enabled             = true
  enable_https_traffic_only = false
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.test.id]
  }
}

# Due to https://github.com/hashicorp/terraform-provider-azurerm/issues/2977 and the fact
# that the NFSv3 enabled storage account can't allow public network access - otherwise the NFSv3 protocol will fail,
# we have to use the ARM template to deploy the storage container as a workaround.
# Once the issue above got resolved, we can instead use the azurerm_storage_container resource.
resource "azurerm_resource_group_template_deployment" "storage-containers" {
  name                = "acctest-strgctn-deployment-210825042917549819"
  resource_group_name = azurerm_storage_account.test.resource_group_name
  deployment_mode     = "Incremental"

  parameters_content = jsonencode({
    name = {
      value = "acctest-strgctn-hpc-210825042917549819"
    }
  })

  template_content = <<EOF
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "String"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts/blobServices/containers",
      "apiVersion": "2019-06-01",
      "name": "[concat('${azurerm_storage_account.test.name}/', 'default/', parameters('name'))]",
      "location": "${azurerm_storage_account.test.location}",
      "properties": {}
    }
  ],

  "outputs": {
    "id": {
      "type": "String",
      "value": "[resourceId('Microsoft.Storage/storageAccounts/blobServices/containers', '${azurerm_storage_account.test.name}', 'default', parameters('name'))]"
    }
  }
}
EOF
}

resource "azurerm_role_assignment" "test_storage_account_contrib" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azuread_service_principal.test.object_id
}

resource "azurerm_role_assignment" "test_storage_blob_data_contrib" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.test.object_id
}

resource "azurerm_hpc_cache" "test" {
  name                = "acctest-HPCC-210825042917549819"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cache_size_in_gb    = 3072
  subnet_id           = azurerm_subnet.test.id
  sku_name            = "Standard_2G"
}


resource "azurerm_hpc_cache_blob_nfs_target" "test" {
  name                 = "acctest-HPCCTGT-f2ym2"
  resource_group_name  = azurerm_resource_group.test.name
  cache_name           = azurerm_hpc_cache.test.name
  storage_container_id = jsondecode(azurerm_resource_group_template_deployment.storage-containers.output_content).id.value
  namespace_path       = "/p1"
  usage_model          = "READ_HEAVY_INFREQ"
}
