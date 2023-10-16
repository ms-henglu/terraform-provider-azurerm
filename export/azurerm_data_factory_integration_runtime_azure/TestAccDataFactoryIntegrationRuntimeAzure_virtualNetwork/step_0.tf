
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-231016033759688932"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                            = "acctestdf231016033759688932"
  location                        = azurerm_resource_group.test.location
  resource_group_name             = azurerm_resource_group.test.name
  managed_virtual_network_enabled = true
}

resource "azurerm_data_factory_integration_runtime_azure" "test" {
  name                    = "azure-integration-runtime"
  data_factory_id         = azurerm_data_factory.test.id
  location                = "AutoResolve"
  virtual_network_enabled = true
}
