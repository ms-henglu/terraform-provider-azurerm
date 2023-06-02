

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-230602030858444752"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-networkmanager-230602030858444752"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}


resource "azurerm_network_manager_subscription_connection" "test" {
  name               = "acctest-nmsc-230602030858444752"
  subscription_id    = data.azurerm_subscription.current.id
  network_manager_id = azurerm_network_manager.test.id
  description        = "complete"
}
