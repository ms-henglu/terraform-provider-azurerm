
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211021234917120880"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest102123491712088"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
