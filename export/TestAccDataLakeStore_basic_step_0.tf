
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220128082321268116"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest012808232126811"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
