
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-df-211029015454594944"
  location = "West Europe"
}

resource "azurerm_data_factory" "test" {
  name                = "acctestdfirsh211029015454594944"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "test" {
  name                = "acctestSIR211029015454594944"
  data_factory_name   = azurerm_data_factory.test.name
  resource_group_name = azurerm_resource_group.test.name
}
