
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221117230719673188"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-221117230719673188"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
