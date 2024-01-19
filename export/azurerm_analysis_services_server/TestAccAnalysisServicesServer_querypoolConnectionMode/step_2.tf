
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-240119024358736409"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                      = "acctestass240119024358736409"
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  sku                       = "B1"
  querypool_connection_mode = "ReadOnly"
}
