
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230428045522564255"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-230428045522564255"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
