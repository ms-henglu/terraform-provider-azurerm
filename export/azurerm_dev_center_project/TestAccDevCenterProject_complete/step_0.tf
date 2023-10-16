

variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 231016033818924819
}
variable "random_string" {
  default = "kvi8o"
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
  dev_center_id          = azurerm_dev_center.test.id
  location               = azurerm_resource_group.test.location
  name                   = "acctestdcp-${var.random_string}"
  resource_group_name    = azurerm_resource_group.test.name
  description            = "Description for the Dev Center Project"
  max_dev_boxes_per_user = 21
  tags = {
    environment = "terraform-acctests"
    some_key    = "some-value"
  }
}
