

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210825044707547217"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest082504470754721"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_store_firewall_rule" "test" {
  name                = "acctest"
  account_name        = azurerm_data_lake_store.test.name
  resource_group_name = azurerm_resource_group.test.name
  start_ip_address    = "1.1.1.1"
  end_ip_address      = "2.2.2.2"
}


resource "azurerm_data_lake_store_firewall_rule" "import" {
  name                = azurerm_data_lake_store_firewall_rule.test.name
  account_name        = azurerm_data_lake_store_firewall_rule.test.account_name
  resource_group_name = azurerm_data_lake_store_firewall_rule.test.resource_group_name
  start_ip_address    = azurerm_data_lake_store_firewall_rule.test.start_ip_address
  end_ip_address      = azurerm_data_lake_store_firewall_rule.test.end_ip_address
}
