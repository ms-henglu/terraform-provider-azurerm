
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-230313021052261257"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfirsh230313021052261257"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "test" {
  name            = "acctestSIR230313021052261257"
  data_factory_id = azurerm_data_factory.test.id
}
