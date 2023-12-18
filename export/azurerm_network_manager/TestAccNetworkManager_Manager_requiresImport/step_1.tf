


provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-231218072256373468"
  location = "West Europe"
}
data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-networkmanager-231218072256373468"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager" "import" {
  name                = azurerm_network_manager.test.name
  location            = azurerm_network_manager.test.location
  resource_group_name = azurerm_network_manager.test.resource_group_name
  scope {
    subscription_ids = azurerm_network_manager.test.scope.0.subscription_ids
  }
  scope_accesses = azurerm_network_manager.test.scope_accesses
}
