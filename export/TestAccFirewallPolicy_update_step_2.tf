

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-210825025818297965"
  location = "West Europe"
}


resource "azurerm_firewall_policy" "test" {
  name                     = "acctest-networkfw-Policy-210825025818297965"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  threat_intelligence_mode = "Off"
  threat_intelligence_allowlist {
    ip_addresses = ["1.1.1.1", "2.2.2.2"]
    fqdns        = ["foo.com", "bar.com"]
  }
  dns {
    servers       = ["1.1.1.1", "2.2.2.2"]
    proxy_enabled = true
  }
  private_ip_ranges = ["172.16.0.0/12", "192.168.0.0/16"]
  tags = {
    env = "Test"
  }
}
