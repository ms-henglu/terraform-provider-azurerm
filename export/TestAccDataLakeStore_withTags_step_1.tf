
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211126031113701173"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest112603111370117"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    environment = "staging"
  }
}
