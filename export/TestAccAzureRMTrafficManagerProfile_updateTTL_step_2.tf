

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-traffic-211013072504593434"
  location = "West Europe"
}


resource "azurerm_traffic_manager_profile" "test" {
  name                   = "acctest-TMP-211013072504593434"
  resource_group_name    = azurerm_resource_group.test.name
  traffic_routing_method = "Geographic"

  dns_config {
    relative_name = "acctest-tmp-211013072504593434"
    ttl           = 2147483647
  }

  monitor_config {
    protocol = "https"
    port     = 443
    path     = "/"
  }
}
