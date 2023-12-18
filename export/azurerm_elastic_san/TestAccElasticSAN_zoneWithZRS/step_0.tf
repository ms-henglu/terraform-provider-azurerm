

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 231218071744532544
}
variable "random_string" {
  default = "z4an3"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


provider "azurerm" {
  features {}
}

resource "azurerm_elastic_san" "test" {
  name                 = "acctestes-${var.random_string}"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  base_size_in_tib     = 1
  extended_size_in_tib = 1
  zones                = ["1"]
  sku {
    name = "Premium_ZRS"
  }
}
