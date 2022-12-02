

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vpnnatrule-221202040145055844"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-221202040145055844"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-vhub-221202040145055844"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_prefix      = "10.0.2.0/24"
  virtual_wan_id      = azurerm_virtual_wan.test.id
}

resource "azurerm_vpn_gateway" "test" {
  name                = "acctest-vpngateway-221202040145055844"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_hub_id      = azurerm_virtual_hub.test.id
}


resource "azurerm_vpn_gateway_nat_rule" "test" {
  name                            = "acctest-vpnnatrule-221202040145055844"
  resource_group_name             = azurerm_resource_group.test.name
  vpn_gateway_id                  = azurerm_vpn_gateway.test.id
  external_address_space_mappings = ["192.168.21.0/26"]
  internal_address_space_mappings = ["10.4.0.0/26"]
}
