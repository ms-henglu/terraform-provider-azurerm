
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220211130452700623"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                     = "acctest021113045270062"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  firewall_state           = "Enabled"
  firewall_allow_azure_ips = "Disabled"
}
