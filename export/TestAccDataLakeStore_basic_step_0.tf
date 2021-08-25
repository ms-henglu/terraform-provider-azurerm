
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210825042752716062"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest082504275271606"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
