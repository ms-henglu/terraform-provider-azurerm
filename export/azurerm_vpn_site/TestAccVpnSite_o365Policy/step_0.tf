

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-rg-230922061636890844"
  location = "West Europe"
}


resource "azurerm_virtual_wan" "test" {
  name                = "acctest-vwan-230922061636890844"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_vpn_site" "test" {
  name                = "acctest-VpnSite-230922061636890844"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  virtual_wan_id      = azurerm_virtual_wan.test.id
  address_cidrs       = ["10.0.0.0/24"]

  o365_policy {
    traffic_category {
      allow_endpoint_enabled    = true
      default_endpoint_enabled  = true
      optimize_endpoint_enabled = true
    }
  }

  link {
    name       = "link1"
    ip_address = "10.0.0.1"
  }
}
