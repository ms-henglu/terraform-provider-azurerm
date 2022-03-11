
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311032342221524"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest4222152"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_analytics_account" "test" {
  name                = "acctest4222152"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  default_store_account_name = azurerm_data_lake_store.test.name
}

resource "azurerm_data_lake_analytics_firewall_rule" "test" {
  name                = "acctest4222152"
  account_name        = azurerm_data_lake_analytics_account.test.name
  resource_group_name = azurerm_resource_group.test.name
  start_ip_address    = "2.2.2.2"
  end_ip_address      = "3.3.3.3"
}
