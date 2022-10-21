
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221021031032271742"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-221021031032271742"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
