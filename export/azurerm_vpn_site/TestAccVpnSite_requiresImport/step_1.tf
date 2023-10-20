


provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-rg-231020041557361555"
  location = "West Europe"
}


resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-231020041557361555"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_vpn_site" "test" {
  name                = "acctest-VpnSite-231020041557361555"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_cidrs       = ["10.0.0.0/24"]
  link {
    name       = "link1"
    ip_address = "10.0.0.1"
  }
}


resource "azurerm_vpn_site" "import" {
  name                = "acctest-VpnSite-231020041557361555"
  location            = azurerm_vpn_site.test.location
  resource_group_name = azurerm_vpn_site.test.resource_group_name
  virtual_wan_id      = azurerm_vpn_site.test.virtual_wan_id
  link {
    name       = "link1"
    ip_address = "10.0.0.1"
  }
}
