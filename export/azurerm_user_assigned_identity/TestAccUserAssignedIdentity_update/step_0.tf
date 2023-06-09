

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 230609091610869786
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


provider "azurerm" {
  features {}
}

resource "azurerm_user_assigned_identity" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestuai-${var.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
}
