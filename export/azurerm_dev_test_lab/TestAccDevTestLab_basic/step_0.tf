
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111020401276267"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl221111020401276267"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
