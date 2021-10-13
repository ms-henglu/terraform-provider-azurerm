

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211013071751259489"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest101307175125948"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_data_lake_store" "import" {
  name                = azurerm_data_lake_store.test.name
  resource_group_name = azurerm_data_lake_store.test.resource_group_name
  location            = azurerm_data_lake_store.test.location
}
