
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220826003111901322"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpublicip-220826003111901322"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  allocation_method = "Static"
  domain_name_label = "18w3zfjadwc3s8uz2g4ytm6ijnuthkgz9ksf36tpqmmhebsfa8m4gqsy6oxjhof"
}
