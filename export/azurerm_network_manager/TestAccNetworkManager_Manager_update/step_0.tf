

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-240119025527690107"
  location = "West Europe"
}
data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-networkmanager-240119025527690107"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}
