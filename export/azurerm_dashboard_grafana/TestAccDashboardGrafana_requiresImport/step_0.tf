
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230630032952129650"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-230630032952129650"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
