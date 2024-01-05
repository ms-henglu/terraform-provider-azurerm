

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240105060656383339
}
variable "random_string" {
  default = "qtffd"
}

resource "azurerm_dev_center" "test" {
  name                = "acctestdc-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


provider "azurerm" {
  features {}
}

resource "azurerm_dev_center_project" "test" {
  dev_center_id       = azurerm_dev_center.test.id
  location            = azurerm_resource_group.test.location
  name                = "acctestdcp-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name
}
