
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-240105063154022622"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass240105063154022622"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B1"
}
