
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025527756159"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan240119025527756159"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  disable_vpn_encryption            = false
  allow_branch_to_branch_traffic    = true
  office365_local_breakout_category = "All"
  type                              = "Standard"

  tags = {
    Hello = "There"
    World = "Example"
  }
}
