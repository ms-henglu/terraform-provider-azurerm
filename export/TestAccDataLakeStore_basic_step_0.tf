
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220204055928716387"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest020405592871638"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
