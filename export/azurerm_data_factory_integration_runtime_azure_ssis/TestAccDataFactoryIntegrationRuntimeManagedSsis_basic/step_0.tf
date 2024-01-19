
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-240119024903038421"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfirm240119024903038421"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_data_factory_integration_runtime_azure_ssis" "test" {
  name            = "managed-integration-runtime"
  data_factory_id = azurerm_data_factory.test.id
  location        = azurerm_resource_group.test.location
  node_size       = "Standard_D8_v3"
}
