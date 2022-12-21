

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vhub-221221204636266605"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-221221204636266605"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-VHUB-221221204636266605"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.2.0/24"
}

resource "azurerm_vpn_gateway" "test" {
  name                = "acctest-VPNG-221221204636266605"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_hub_id      = azurerm_virtual_hub.test.id
}


resource "azurerm_virtual_hub_security_partner_provider" "test" {
  name                   = "acctest-SPP-221221204636266605"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  security_provider_name = "ZScaler"

  depends_on = [azurerm_vpn_gateway.test]
}
