
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240119024809367791"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                  = "a-dg-240119024809367791"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  grafana_major_version = "9"

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-240119024809367791"
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-240119024809367791-2"
  }

  tags = {
    key2 = "value2"
  }
}
