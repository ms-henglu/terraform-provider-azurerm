
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220114014124375019"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest2eymg"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_type     = "ServiceManaged"
}
