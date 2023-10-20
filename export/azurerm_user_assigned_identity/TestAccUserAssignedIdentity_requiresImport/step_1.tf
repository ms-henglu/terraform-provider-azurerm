


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 231020041410830636
}
variable "random_string" {
  default = "2o3fu"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}


provider "azurerm" {
  features {}
}

resource "azurerm_user_assigned_identity" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestuai-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_user_assigned_identity" "import" {
  location            = azurerm_user_assigned_identity.test.location
  name                = azurerm_user_assigned_identity.test.name
  resource_group_name = azurerm_user_assigned_identity.test.resource_group_name
}
