

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240112034350475141
}
variable "random_string" {
  default = "n3em2"
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
  base_size_in_tib     = 2
  extended_size_in_tib = 4
  zones                = ["1", "2"]
  sku {
    name = "Premium_LRS"
    tier = "Premium"
  }
  tags = {
    environment = "terraform-acctests"
    some_key    = "some-value"
  }
}
