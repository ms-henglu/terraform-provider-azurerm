
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210825031611450059"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest082503161145005"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
