
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230227032511097131"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                              = "a-dg-230227032511097131"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = false

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-230227032511097131"
  }

  tags = {
    key = "value"
  }
}
