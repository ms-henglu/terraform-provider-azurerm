
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211119050817844766"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl211119050817844766"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
