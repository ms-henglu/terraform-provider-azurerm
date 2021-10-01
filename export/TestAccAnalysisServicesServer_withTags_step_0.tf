
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-211001053416328697"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass211001053416328697"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B1"

  tags = {
    label = "test"
  }
}
