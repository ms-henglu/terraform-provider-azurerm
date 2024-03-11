
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311031750241335"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                  = "a-dg-240311031750241335"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  grafana_major_version = "10"

}
