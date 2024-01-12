
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240112224333471794"
  location = "West Europe"
}

resource "azurerm_key_vault" "test" {
  name                = "acctkv240112224333471794"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdf240112224333471794"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_data_factory_linked_service_key_vault" "test" {
  name            = "linkkv"
  data_factory_id = azurerm_data_factory.test.id
  key_vault_id    = azurerm_key_vault.test.id
}

resource "azurerm_data_factory_linked_service_azure_function" "test" {
  name            = "acctestlsblob240112224333471794"
  data_factory_id = azurerm_data_factory.test.id
  url             = "foo"
  key_vault_key {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.test.name
    secret_name         = "secret"
  }
}
