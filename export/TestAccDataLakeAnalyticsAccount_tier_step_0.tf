

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211210024515373952"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest121002451537395"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_data_lake_analytics_account" "test" {
  name                = "acctest121002451537395"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tier = "Commitment_100AUHours"

  default_store_account_name = azurerm_data_lake_store.test.name
}
