
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210917031630732255"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl210917031630732255"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
