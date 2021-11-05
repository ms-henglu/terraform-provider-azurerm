
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-211105040239985747"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-211105040239985747"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
