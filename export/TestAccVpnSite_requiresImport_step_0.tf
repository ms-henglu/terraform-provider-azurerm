

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-rg-211112021019986916"
  location = "West Europe"
}


resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-211112021019986916"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_vpn_site" "test" {
  name                = "acctest-VpnSite-211112021019986916"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_wan_id      = azurerm_virtual_wan.test.id
  link {
    name       = "link1"
    ip_address = "10.0.0.1"
  }
}
