

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vpnnatrule-240112224958324198"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-240112224958324198"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-vhub-240112224958324198"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_prefix      = "10.0.2.0/24"
  virtual_wan_id      = azurerm_virtual_wan.test.id
}

resource "azurerm_vpn_gateway" "test" {
  name                = "acctest-vpngateway-240112224958324198"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_hub_id      = azurerm_virtual_hub.test.id
}


resource "azurerm_vpn_gateway_nat_rule" "test" {
  name                = "acctest-vpnnatrule-240112224958324198"
  resource_group_name = azurerm_resource_group.test.name
  vpn_gateway_id      = azurerm_vpn_gateway.test.id

  external_mapping {
    address_space = "10.3.0.0/26"
    port_range    = "300"
  }

  internal_mapping {
    address_space = "10.5.0.0/26"
    port_range    = "500"
  }
}
