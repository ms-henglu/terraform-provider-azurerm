
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210928075402885502"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest092807540288550"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
