
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211210024515403966"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                     = "acctest121002451540396"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  firewall_state           = "Disabled"
  firewall_allow_azure_ips = "Disabled"
}
