
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230707003651519731"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-230707003651519731"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
