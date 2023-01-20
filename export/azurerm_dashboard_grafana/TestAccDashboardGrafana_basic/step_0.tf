
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230120051759360865"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-230120051759360865"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
