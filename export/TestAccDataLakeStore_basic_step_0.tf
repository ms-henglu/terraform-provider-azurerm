
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210830083908322386"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest083008390832238"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
