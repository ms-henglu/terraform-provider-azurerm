
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-221117230800972741"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfirm221117230800972741"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_data_factory_integration_runtime_azure" "test" {
  name             = "azure-integration-runtime"
  data_factory_id  = azurerm_data_factory.test.id
  location         = azurerm_resource_group.test.location
  time_to_live_min = 10
}
