
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220114014124371089"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest011401412437108"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
