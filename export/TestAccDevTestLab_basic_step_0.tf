
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210826023330821725"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl210826023330821725"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
