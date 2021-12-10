
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211210034559738636"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest121003455973863"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
