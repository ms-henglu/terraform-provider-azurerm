
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025027118245"
  location = "West Europe"
}

resource "azurerm_eventgrid_domain" "test" {
  name                = "acctesteg-240119025027118245"
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
