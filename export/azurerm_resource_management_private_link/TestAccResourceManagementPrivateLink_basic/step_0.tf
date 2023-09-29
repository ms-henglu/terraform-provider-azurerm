
provider "azurerm" {
  features {}
}


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 230929065615639502
}
variable "random_string" {
  default = "9w26b"
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
