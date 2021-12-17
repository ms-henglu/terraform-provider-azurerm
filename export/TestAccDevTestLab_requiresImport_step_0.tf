
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075221162287"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl211217075221162287"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
