
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004222079368"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl210924004222079368"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
