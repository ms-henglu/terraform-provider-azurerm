
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033826760255"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl231016033826760255"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
