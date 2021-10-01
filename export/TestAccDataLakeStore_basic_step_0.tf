
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211001053645644453"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest100105364564445"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
