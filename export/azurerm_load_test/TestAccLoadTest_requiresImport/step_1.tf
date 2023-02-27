


provider "azurerm" {
  features {}
}

locals {
  random_integer   = 230227032927086169
  primary_location = "West Europe"
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${local.random_integer}"
  location = local.primary_location
}


resource "azurerm_load_test" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctest-${local.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_load_test" "import" {
  location            = azurerm_resource_group.test.location
  name                = "acctest-${local.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
}
