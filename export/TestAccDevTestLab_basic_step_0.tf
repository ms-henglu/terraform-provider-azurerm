
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021234944045762"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl211021234944045762"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
