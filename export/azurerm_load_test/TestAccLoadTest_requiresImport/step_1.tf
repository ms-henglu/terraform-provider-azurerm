


variable "primary_location" {
  default = "West Europe"
}
variable "random_integer" {
  default = 240105064047404818
}
variable "random_string" {
  default = "nf6r2"
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

resource "azurerm_load_test" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctestlt-${var.random_string}"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_load_test" "import" {
  location            = azurerm_load_test.test.location
  name                = azurerm_load_test.test.name
  resource_group_name = azurerm_load_test.test.resource_group_name
}
