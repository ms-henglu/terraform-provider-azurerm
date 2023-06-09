
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230609091224118679"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl230609091224118679"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
