
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230127045223635037"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-230127045223635037"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
