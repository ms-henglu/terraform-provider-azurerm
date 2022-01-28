
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220128082321266960"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctestrkbag"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_type     = "ServiceManaged"
}
