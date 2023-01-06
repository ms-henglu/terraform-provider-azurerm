
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230106034316797365"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                              = "a-dg-230106034316797365"
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
