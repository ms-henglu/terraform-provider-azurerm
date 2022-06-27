
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220627125811307130"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest062712581130713"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
