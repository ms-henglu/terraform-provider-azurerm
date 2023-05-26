
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230526084904376053"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-230526084904376053"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-230526084904376053"
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-230526084904376053-2"
  }

  tags = {
    key2 = "value2"
  }
}
