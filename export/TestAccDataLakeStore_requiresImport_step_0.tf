
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211015014535996307"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest101501453599630"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
