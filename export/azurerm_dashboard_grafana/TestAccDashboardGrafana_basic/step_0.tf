
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230203063132691361"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-230203063132691361"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
