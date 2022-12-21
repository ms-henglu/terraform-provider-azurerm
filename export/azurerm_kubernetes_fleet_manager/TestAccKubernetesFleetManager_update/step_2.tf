

provider "azurerm" {
  features {}
}

locals {
  random_integer   = 221221204115087038
  primary_location = "West Europe"
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${local.random_integer}"
  location = local.primary_location
}



resource "azurerm_kubernetes_fleet_manager" "test" {
  location            = azurerm_resource_group.test.location
  name                = "acctest-${local.random_integer}"
  resource_group_name = azurerm_resource_group.test.name

  hub_profile {
    dns_prefix = "acctest"
  }

  tags = {
    env  = "Production"
    test = "Acceptance"
  }
}
