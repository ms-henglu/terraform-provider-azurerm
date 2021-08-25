
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210825042752710140"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest082504275271014"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_data_lake_store_firewall_rule" "test" {
  name                = "acctest"
  account_name        = azurerm_data_lake_store.test.name
  resource_group_name = azurerm_resource_group.test.name
  start_ip_address    = "2.2.2.2"
  end_ip_address      = "3.3.3.3"
}
