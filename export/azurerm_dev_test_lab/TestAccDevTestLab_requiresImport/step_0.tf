
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024928809323"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl240119024928809323"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
