
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-220627134819015458"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-220627134819015458"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
