
provider "azurerm" {
  features {}
}

resource "azurerm_management_group" "grandparent" {
}

resource "azurerm_management_group" "parent" {
  parent_management_group_id = azurerm_management_group.grandparent.id
}

resource "azurerm_management_group" "child" {
  parent_management_group_id = azurerm_management_group.parent.id
}
