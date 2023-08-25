
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230825024423943435"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230825024423943435"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {
}

resource "azurerm_storage_account" "test" {
  name                      = "accsa230825024423943435"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_data_factory.test.identity.0.principal_id
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name                 = "acctestBlobStorage230825024423943435"
  data_factory_id      = azurerm_data_factory.test.id
  service_endpoint     = azurerm_storage_account.test.primary_blob_endpoint
  use_managed_identity = true
  storage_kind         = "StorageV2"
}
