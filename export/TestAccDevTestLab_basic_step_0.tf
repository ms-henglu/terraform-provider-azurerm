
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211029015532942587"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl211029015532942587"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
