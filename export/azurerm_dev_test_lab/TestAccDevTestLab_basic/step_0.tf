
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221221204231494752"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl221221204231494752"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
