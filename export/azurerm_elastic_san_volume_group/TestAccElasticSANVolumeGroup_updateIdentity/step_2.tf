

variable "primary_location" {
  default = "westus2"
}
variable "random_integer" {
  default = 240311032047564943
}
variable "random_string" {
  default = "z8xrh"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-esvg-${var.random_integer}"
  location = var.primary_location
}

resource "azurerm_elastic_san" "test" {
  name                = "acctestes-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  base_size_in_tib    = 1
  sku {
    name = "Premium_LRS"
  }
}


provider "azurerm" {
  features {}
}

resource "azurerm_elastic_san_volume_group" "test" {
  name           = "acctestesvg-${var.random_string}"
  elastic_san_id = azurerm_elastic_san.test.id

  identity {
    type = "SystemAssigned"
  }
}
