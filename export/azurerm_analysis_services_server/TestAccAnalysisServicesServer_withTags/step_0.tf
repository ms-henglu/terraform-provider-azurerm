
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-analysis-230227175042004140"
  location = "West Europe"
}

resource "azurerm_analysis_services_server" "test" {
  name                = "acctestass230227175042004140"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "B1"

  tags = {
    label = "test"
  }
}
