
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-fw-230421022204610342"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                = "acctest-firewallpolicy-230421022204610342"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctest-virtualwan-230421022204610342"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_virtual_hub" "test" {
  name                = "acctest-virtualhub-230421022204610342"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_prefix      = "10.0.1.0/24"
}

resource "azurerm_firewall" "test" {
  name                = "acctest-firewall-230421022204610342"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "AZFW_Hub"
  sku_tier            = "Standard"

  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.test.id
    public_ip_count = 2
  }

  firewall_policy_id = azurerm_firewall_policy.test.id
}
