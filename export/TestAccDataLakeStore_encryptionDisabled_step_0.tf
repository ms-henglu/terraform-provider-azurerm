
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211210034559739961"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest121003455973996"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  encryption_state    = "Disabled"
}
