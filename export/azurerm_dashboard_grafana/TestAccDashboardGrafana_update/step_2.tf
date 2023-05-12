
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230512010504612080"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-230512010504612080"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-230512010504612080"
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-230512010504612080-2"
  }

  tags = {
    key2 = "value2"
  }
}
