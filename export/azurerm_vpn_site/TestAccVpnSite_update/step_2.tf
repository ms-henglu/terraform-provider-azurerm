

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-rg-231013043954372590"
  location = "West Europe"
}


resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-231013043954372590"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_vpn_site" "test" {
  name                = "acctest-VpnSite-231013043954372590"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_cidrs       = ["10.0.0.0/24", "10.0.1.0/24"]

  device_vendor = "Cisco"
  device_model  = "foobar"

  link {
    name          = "link1"
    provider_name = "Verizon"
    speed_in_mbps = 50
    ip_address    = "10.0.0.1"
    bgp {
      asn             = 12345
      peering_address = "10.0.0.1"
    }
  }

  link {
    name = "link2"
    fqdn = "foo.com"
  }
  tags = {
    ENV = "Test"
  }
}
