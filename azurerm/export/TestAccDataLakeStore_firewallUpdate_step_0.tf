
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220627131814291741"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                     = "acctest062713181429174"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  firewall_state           = "Enabled"
  firewall_allow_azure_ips = "Enabled"
}
