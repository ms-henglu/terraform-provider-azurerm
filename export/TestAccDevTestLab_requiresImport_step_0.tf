
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220712042218282467"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl220712042218282467"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
