
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721015711411039"
  location = "West Europe"
}

resource "azurerm_virtual_wan" "test" {
  name                = "acctestvwan230721015711411039"
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
