
provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults    = false
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915024202391719"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccluec7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_key_vault" "test" {
  name                     = "accAKV-luec7"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = true
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "testspringcloudservice-luec7"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_spring_cloud_app" "test" {
  name                = "testspringcloud-luec7"
  resource_group_name = azurerm_resource_group.test.name
  service_name        = azurerm_spring_cloud_service.test.name

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_spring_cloud_java_deployment" "test" {
  name                = "deploy-luec7"
  spring_cloud_app_id = azurerm_spring_cloud_app.test.id
}


resource "azurerm_spring_cloud_connection" "test" {
  name               = "acctestserviceconnector230915024202391719"
  spring_cloud_id    = azurerm_spring_cloud_java_deployment.test.id
  target_resource_id = azurerm_storage_account.test.id

  secret_store {
    key_vault_id = azurerm_key_vault.test.id
  }
  authentication {
    type = "systemAssignedIdentity"
  }
}
