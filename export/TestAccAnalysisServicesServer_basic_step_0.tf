
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-220610022154088843"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass220610022154088843"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B1"
}
