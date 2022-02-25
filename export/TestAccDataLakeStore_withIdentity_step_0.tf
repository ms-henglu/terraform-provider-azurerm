
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220225034259838527"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest022503425983852"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
