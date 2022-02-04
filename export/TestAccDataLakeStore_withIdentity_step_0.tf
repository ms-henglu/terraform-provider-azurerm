
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220204092903556438"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest020409290355643"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
