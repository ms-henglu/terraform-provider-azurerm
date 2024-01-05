

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240105063717843214
}
variable "random_string" {
  default = "6n9s9"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-${var.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


provider "azurerm" {
  features {}
}

resource "azurerm_dev_center" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestdc-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name
}
