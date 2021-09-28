
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210928055349235372"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest092805534923537"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
