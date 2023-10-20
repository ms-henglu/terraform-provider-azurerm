
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041006819000"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl231020041006819000"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
