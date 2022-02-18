
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220218070714765842"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220218070714765842"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
