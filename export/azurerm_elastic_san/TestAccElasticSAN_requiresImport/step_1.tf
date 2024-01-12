


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240112034350479174
}
variable "random_string" {
  default = "1zv7k"
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
}


resource "azurerm_elastic_san" "import" {
  name                = azurerm_elastic_san.test.name
  resource_group_name = azurerm_elastic_san.test.resource_group_name
  location            = azurerm_elastic_san.test.location
  base_size_in_tib    = azurerm_elastic_san.test.base_size_in_tib
  zones               = azurerm_elastic_san.test.zones
  sku {
    name = azurerm_elastic_san.test.sku.0.name
  }
}
