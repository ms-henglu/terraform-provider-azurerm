
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220128082321265561"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest012808232126556"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
