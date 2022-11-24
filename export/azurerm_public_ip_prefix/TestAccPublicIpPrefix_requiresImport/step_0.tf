
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124182052965082"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-221124182052965082"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
