
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220506015837452568"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220506015837452568"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
