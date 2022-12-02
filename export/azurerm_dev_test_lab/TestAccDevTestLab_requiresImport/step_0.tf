
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221202035550707024"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl221202035550707024"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
