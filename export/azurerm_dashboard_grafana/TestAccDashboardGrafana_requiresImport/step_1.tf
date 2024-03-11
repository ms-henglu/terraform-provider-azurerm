
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311031750242857"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                  = "a-dg-240311031750242857"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  grafana_major_version = "9"
}


resource "azurerm_dashboard_grafana" "import" {
  name                  = azurerm_dashboard_grafana.test.name
  resource_group_name   = azurerm_dashboard_grafana.test.resource_group_name
  location              = azurerm_dashboard_grafana.test.location
  grafana_major_version = "9"
}
