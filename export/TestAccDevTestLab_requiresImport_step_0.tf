
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220408051214890077"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220408051214890077"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
