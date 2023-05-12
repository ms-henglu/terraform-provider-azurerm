
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230512010504611899"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-230512010504611899"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_dashboard_grafana" "import" {
  name                = azurerm_dashboard_grafana.test.name
  resource_group_name = azurerm_dashboard_grafana.test.resource_group_name
  location            = azurerm_dashboard_grafana.test.location
}
