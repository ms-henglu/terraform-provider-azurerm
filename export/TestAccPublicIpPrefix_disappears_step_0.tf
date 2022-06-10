
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220610022923595218"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-220610022923595218"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
