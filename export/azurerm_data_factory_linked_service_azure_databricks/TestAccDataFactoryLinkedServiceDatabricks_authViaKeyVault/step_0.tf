
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}
// Create the RG
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119021929371023"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240119021929371023"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


// Create a key vault so we can setup a KV linked service
resource "azurerm_key_vault" "test" {
  name                = "acctkv240119021929371023"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

// Create the KV linked service so we can test out integration the Databricks linked service
resource "azurerm_data_factory_linked_service_key_vault" "test" {
  name            = "linkkv"
  data_factory_id = azurerm_data_factory.test.id
  key_vault_id    = azurerm_key_vault.test.id
}

// Create a databricks linked service that leveraged the KV linked service for password management
resource "azurerm_data_factory_linked_service_azure_databricks" "test" {
  name            = "acctestDatabricksLinkedService240119021929371023"
  data_factory_id = azurerm_data_factory.test.id
  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.test.name
    secret_name         = "secret"
  }
  description = "Initial description"
  annotations = ["test1", "test2"]
  adb_domain  = "https://adb-111111111.11.azuredatabricks.net"
  instance_pool {
    instance_pool_id      = "0308-201055-safes631-pool-EHfwukQo"
    min_number_of_workers = 3
    cluster_version       = "5.5.x-gpu-scala2.11"
  }
}
