
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627131110227435"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220627131110227435"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
