
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016033705064847"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-231016033705064847"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-231016033705064847"
  }

  azure_monitor_workspace_integrations {
    resource_id = "${azurerm_resource_group.test.id}/providers/microsoft.monitor/accounts/a-mwr-231016033705064847-2"
  }

  tags = {
    key2 = "value2"
  }
}
