
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221222034453508196"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-221222034453508196"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
