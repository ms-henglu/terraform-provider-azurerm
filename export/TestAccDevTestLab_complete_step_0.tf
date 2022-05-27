
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220527034110034661"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220527034110034661"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  storage_type        = "Standard"

  tags = {
    Hello = "World"
  }
}
