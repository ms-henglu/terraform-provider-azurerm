
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181032484034"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl230113181032484034"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
