
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230428050247016214"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-230428050247016214"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
