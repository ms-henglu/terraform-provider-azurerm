
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231013043234899059"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-231013043234899059"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
