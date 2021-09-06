
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210906022156872226"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest090602215687222"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
