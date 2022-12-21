

provider "azurerm" {
  features {}
}

locals {
  random_integer   = 221221204533358965
  primary_location = "West Europe"
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${local.random_integer}"
  location = local.primary_location
}



resource "azurerm_user_assigned_identity" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctest-${local.random_integer}"
  resource_group_name = azurerm_resource_group.test.name
  tags = {
    env  = "Production"
    test = "Acceptance"
  }
}
