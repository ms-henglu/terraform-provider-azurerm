
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074649859097"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl230519074649859097"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
