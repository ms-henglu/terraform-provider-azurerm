
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-210928055341224998"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestdf210928055341224998"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}

resource "azurerm_data_factory_integration_runtime_azure" "test" {
  name                    = "azure-integration-runtime"
  data_factory_name       = azurerm_data_factory.test.name
  resource_group_name     = azurerm_resource_group.test.name
  location                = azurerm_resource_group.test.location
  virtual_network_enabled = true
}
