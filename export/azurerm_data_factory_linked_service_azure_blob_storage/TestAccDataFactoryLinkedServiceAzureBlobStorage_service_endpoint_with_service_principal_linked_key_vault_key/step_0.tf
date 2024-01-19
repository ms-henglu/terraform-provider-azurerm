
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119024903030417"
  location = "West Europe"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240119024903030417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault" "test" {
  name                = "acctkv240119024903030417"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_data_factory_linked_service_key_vault" "test" {
  name            = "linkkv"
  data_factory_id = azurerm_data_factory.test.id
  key_vault_id    = azurerm_key_vault.test.id
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "test" {
  name                 = "acctestBlobStorage"
  data_factory_id      = azurerm_data_factory.test.id
  service_endpoint     = "https://storageaccountname.blob.core.windows.net"
  service_principal_id = data.azurerm_client_config.current.client_id
  tenant_id            = "ARM_TENANT_ID"
  service_principal_linked_key_vault_key {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.test.name
    secret_name         = "secret"
  }
}
