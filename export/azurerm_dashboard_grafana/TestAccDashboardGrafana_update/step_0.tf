
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311031750243584"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "a-uid-240311031750243584"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_dashboard_grafana" "test" {
  name                              = "a-dg-240311031750243584"
  resource_group_name               = azurerm_resource_group.test.name
  location                          = azurerm_resource_group.test.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = false
  grafana_major_version             = "9"
  smtp {
    enabled          = true
    host             = "localhost:25"
    user             = "user"
    password         = "password"
    from_address     = "admin@grafana.localhost"
    from_name        = "Grafana"
    start_tls_policy = "OpportunisticStartTLS"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-240311031750243584"
  }

  tags = {
    key = "value"
  }
}
