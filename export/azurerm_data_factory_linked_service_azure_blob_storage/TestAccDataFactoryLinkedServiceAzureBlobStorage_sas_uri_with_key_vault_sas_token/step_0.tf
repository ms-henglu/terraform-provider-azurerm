
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230227032558091236"
  location = "West Europe"
}

data "azurerm_client_config" "current" {
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230227032558091236"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault" "test" {
  name                = "acctkv230227032558091236"
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
  name            = "acctestBlobStorage"
  data_factory_id = azurerm_data_factory.test.id
  sas_uri         = "https://storageaccountname.blob.core.windows.net"
  key_vault_sas_token {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.test.name
    secret_name         = "secret"
  }
}
