
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211022001927755822"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl211022001927755822"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
