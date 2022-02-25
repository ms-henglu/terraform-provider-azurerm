
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220225034259838744"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                     = "acctest022503425983874"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  firewall_state           = "Disabled"
  firewall_allow_azure_ips = "Enabled"
}
