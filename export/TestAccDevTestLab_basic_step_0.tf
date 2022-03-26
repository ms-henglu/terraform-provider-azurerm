
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220326010446388363"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220326010446388363"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
