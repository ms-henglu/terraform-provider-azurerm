

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vpnnatrule-231218072256490922"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-231218072256490922"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-vhub-231218072256490922"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_prefix      = "10.0.2.0/24"
  virtual_wan_id      = azurerm_virtual_wan.test.id
}

resource "azurerm_vpn_gateway" "test" {
  name                = "acctest-vpngateway-231218072256490922"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_hub_id      = azurerm_virtual_hub.test.id
}


resource "azurerm_vpn_gateway_nat_rule" "test" {
  name                = "acctest-vpnnatrule-231218072256490922"
  resource_group_name = azurerm_resource_group.test.name
  vpn_gateway_id      = azurerm_vpn_gateway.test.id

  external_mapping {
    address_space = "10.2.0.0/26"
    port_range    = "200"
  }

  internal_mapping {
    address_space = "10.4.0.0/26"
    port_range    = "400"
  }
}
