
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220726001838086309"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220726001838086309"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
