
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230922061010020439"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctkv230922061010020439"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf230922061010020439"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_key_vault" "test" {
  name            = "linkkv"
  data_factory_id = azurerm_data_factory.test.id
  key_vault_id    = azurerm_key_vault.test.id
}

resource "azurerm_data_factory_linked_service_azure_sql_database" "test" {
  name            = "acctestlssql230922061010020439"
  data_factory_id = azurerm_data_factory.test.id

  key_vault_connection_string {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.test.name
    secret_name         = "connection_string"
  }

  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.test.name
    secret_name         = "password"
  }
}
