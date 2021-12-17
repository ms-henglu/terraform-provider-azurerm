
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211217075142516035"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest121707514251603"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
