
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-211210034312269073"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass211210034312269073"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B1"

  tags = {
    label = "test"
  }
}
