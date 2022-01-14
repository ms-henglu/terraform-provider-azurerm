

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220114064037587065"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest011406403758706"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_data_lake_analytics_account" "test" {
  name                = "acctest011406403758706"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tier = "Commitment_100AUHours"

  default_store_account_name = azurerm_data_lake_store.test.name
}
