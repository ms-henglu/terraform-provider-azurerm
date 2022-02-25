
provider "azurerm" {
  features {}
}
data "azurerm_client_config" "current" {}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-220225034258404423"
  location = "West Europe"
}
resource "azurerm_key_vault" "test" {
  name                = "acctkv220225034258404423"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}
resource "azurerm_data_factory" "test" {
  name                = "acctestdf220225034258404423"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_data_factory_linked_service_key_vault" "test" {
  name                = "linkkv"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_name   = azurerm_data_factory.test.name
  key_vault_id        = azurerm_key_vault.test.id
}
resource "azurerm_data_factory_linked_service_azure_file_storage" "test" {
  name                = "acctestlsblob220225034258404423"
  resource_group_name = azurerm_resource_group.test.name
  data_factory_id     = azurerm_data_factory.test.id
  connection_string   = "DefaultEndpointsProtocol=https;AccountName=foo;AccountKey=bar"
  file_share          = "myshare"
  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.test.name
    secret_name         = "secret"
  }
}
