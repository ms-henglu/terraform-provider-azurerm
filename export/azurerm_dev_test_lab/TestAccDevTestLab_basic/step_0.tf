
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023320590717"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl230915023320590717"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
