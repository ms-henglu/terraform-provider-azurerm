
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210917031601588054"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest091703160158805"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
