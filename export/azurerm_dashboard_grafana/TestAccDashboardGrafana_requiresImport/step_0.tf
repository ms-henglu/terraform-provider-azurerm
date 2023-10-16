
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016033705061245"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-231016033705061245"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
