
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-220726014441747144"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                    = "acctestass220726014441747144"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  sku                     = "B1"
  enable_power_bi_service = true
}
