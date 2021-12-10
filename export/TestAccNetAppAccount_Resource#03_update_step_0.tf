
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-211210024854772142"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-211210024854772142"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
