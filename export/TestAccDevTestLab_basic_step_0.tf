
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220211130532238602"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220211130532238602"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
