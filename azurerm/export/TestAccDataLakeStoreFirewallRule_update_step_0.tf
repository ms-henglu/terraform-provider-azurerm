
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220627134437902601"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest062713443790260"
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
