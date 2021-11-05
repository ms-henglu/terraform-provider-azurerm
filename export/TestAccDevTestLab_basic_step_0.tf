
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105035838686961"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl211105035838686961"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
