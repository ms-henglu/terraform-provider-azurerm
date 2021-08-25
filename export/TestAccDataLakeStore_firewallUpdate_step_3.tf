
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210825044707546510"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                     = "acctest082504470754651"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  firewall_state           = "Disabled"
  firewall_allow_azure_ips = "Disabled"
}
