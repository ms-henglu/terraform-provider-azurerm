

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211029015500753958"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest102901550075395"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_data_lake_analytics_account" "test" {
  name                = "acctest102901550075395"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  default_store_account_name = azurerm_data_lake_store.test.name
}
