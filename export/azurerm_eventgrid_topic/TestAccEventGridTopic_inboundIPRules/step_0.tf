
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028172133633256"
  location = "West Europe"
}

resource "azurerm_eventgrid_topic" "test" {
  name                = "acctesteg-221028172133633256"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  public_network_access_enabled = true

  inbound_ip_rule {
    ip_mask = "10.0.0.0/16"
    action  = "Allow"
  }

  inbound_ip_rule {
    ip_mask = "10.1.0.0/16"
    action  = "Allow"
  }
}
