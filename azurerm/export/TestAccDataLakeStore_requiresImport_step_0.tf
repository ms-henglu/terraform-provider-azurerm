
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220627134437901359"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest062713443790135"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
