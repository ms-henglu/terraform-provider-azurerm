
provider "azurerm" {
  features {}
}


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 231016034629737480
}
variable "random_string" {
  default = "n32ue"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


resource "azurerm_resource_management_private_link" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestrmpl-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name
}
