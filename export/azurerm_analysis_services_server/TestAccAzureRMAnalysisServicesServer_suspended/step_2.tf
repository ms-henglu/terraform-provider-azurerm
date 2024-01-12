
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-240112033736620889"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass240112033736620889"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B2"
}
