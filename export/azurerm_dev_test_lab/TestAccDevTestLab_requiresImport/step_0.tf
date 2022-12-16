
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013437559153"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctestdtl221216013437559153"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
