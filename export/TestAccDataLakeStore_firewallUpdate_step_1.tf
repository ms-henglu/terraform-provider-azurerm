
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220204055928714618"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                     = "acctest020405592871461"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  firewall_state           = "Enabled"
  firewall_allow_azure_ips = "Disabled"
}
