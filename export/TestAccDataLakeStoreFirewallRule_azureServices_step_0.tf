
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211105035803883843"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest110503580388384"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_store_firewall_rule" "test" {
  name                = "acctest"
  account_name        = azurerm_data_lake_store.test.name
  resource_group_name = azurerm_resource_group.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
