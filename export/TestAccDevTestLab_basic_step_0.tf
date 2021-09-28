
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055414013986"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl210928055414013986"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
