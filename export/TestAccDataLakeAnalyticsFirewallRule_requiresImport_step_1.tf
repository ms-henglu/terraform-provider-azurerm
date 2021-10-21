

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211021234917097392"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest1709739"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_analytics_account" "test" {
  name                = "acctest1709739"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  default_store_account_name = azurerm_data_lake_store.test.name
}

resource "azurerm_data_lake_analytics_firewall_rule" "test" {
  name                = "acctest1709739"
  account_name        = azurerm_data_lake_analytics_account.test.name
  resource_group_name = azurerm_resource_group.test.name
  start_ip_address    = "1.1.1.1"
  end_ip_address      = "2.2.2.2"
}


resource "azurerm_data_lake_analytics_firewall_rule" "import" {
  name                = azurerm_data_lake_analytics_firewall_rule.test.name
  account_name        = azurerm_data_lake_analytics_firewall_rule.test.account_name
  resource_group_name = azurerm_data_lake_analytics_firewall_rule.test.resource_group_name
  start_ip_address    = azurerm_data_lake_analytics_firewall_rule.test.start_ip_address
  end_ip_address      = azurerm_data_lake_analytics_firewall_rule.test.end_ip_address
}
