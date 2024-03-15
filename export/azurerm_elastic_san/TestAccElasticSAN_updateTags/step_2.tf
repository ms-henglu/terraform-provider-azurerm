

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240315123014971857
}
variable "random_string" {
  default = "44e7w"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


provider "azurerm" {
  features {}
}

resource "azurerm_elastic_san" "test" {
  name                = "acctestes-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  base_size_in_tib    = 1
  sku {
    name = "Premium_LRS"
  }
  tags = {
    foo = "bar"
  }
}
