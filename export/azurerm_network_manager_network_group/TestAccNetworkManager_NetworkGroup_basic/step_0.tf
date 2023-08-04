
				
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-230804030421759785"
  location = "West Europe"
}
data "azurerm_subscription" "current" {
}
resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-230804030421759785"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-230804030421759785"
  network_manager_id = azurerm_network_manager.test.id
}
