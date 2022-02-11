
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220211043507750092"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest021104350775009"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
