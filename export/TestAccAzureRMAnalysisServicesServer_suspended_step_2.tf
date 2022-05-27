
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-220527033755434202"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass220527033755434202"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B2"
}
