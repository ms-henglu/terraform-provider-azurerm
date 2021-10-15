
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211015014135244103"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest101501413524410"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
