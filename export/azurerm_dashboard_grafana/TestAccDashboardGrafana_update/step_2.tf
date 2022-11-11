
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-221111013333442460"
  location = "West Europe"
}


resource "azurerm_dashboard_grafana" "test" {
  name                = "a-dg-221111013333442460"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }

  tags = {
    key2 = "value2"
  }
}
