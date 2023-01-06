
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230106031311516662"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                              = "a-dg-230106031311516662"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = false

  identity {
    type = "SystemAssigned"
  }

  tags = {
    key = "value"
  }
}
