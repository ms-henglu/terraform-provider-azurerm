
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072256423083"
  location = "West Europe"
}

resource "azurerm_public_ip_prefix" "test" {
  name                = "acctestpublicipprefix-231218072256423083"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
