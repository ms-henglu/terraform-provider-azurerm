
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313021116590554"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl230313021116590554"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
