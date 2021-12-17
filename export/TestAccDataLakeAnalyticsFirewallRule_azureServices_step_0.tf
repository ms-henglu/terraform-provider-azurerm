
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217075142473133"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest4247313"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_analytics_account" "test" {
  name                = "acctest4247313"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  default_store_account_name = azurerm_data_lake_store.test.name
}

resource "azurerm_data_lake_analytics_firewall_rule" "test" {
  name                = "acctest4247313"
  account_name        = azurerm_data_lake_analytics_account.test.name
  resource_group_name = azurerm_resource_group.test.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
