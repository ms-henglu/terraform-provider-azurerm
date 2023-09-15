
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023548190411"
  location = "West Europe"
}

resource "azurerm_iothub_dps" "test" {
  name                          = "acctestIoTDPS-230915023548190411"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  public_network_access_enabled = false

  ip_filter_rule {
    name    = "test"
    ip_mask = "10.0.0.0/31"
    action  = "Reject"
    target  = "all"
  }

  ip_filter_rule {
    name    = "test2"
    ip_mask = "10.0.2.0/31"
    action  = "Reject"
    target  = "deviceApi"
  }

  ip_filter_rule {
    name    = "test3"
    ip_mask = "10.0.3.0/31"
    action  = "Accept"
  }

  sku {
    name     = "S1"
    capacity = "1"
  }
}
