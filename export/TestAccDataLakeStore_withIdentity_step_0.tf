
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211112020512511777"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest111202051251177"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
