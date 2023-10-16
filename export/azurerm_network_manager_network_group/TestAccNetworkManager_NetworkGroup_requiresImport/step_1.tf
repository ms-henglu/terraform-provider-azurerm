
			
				
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-231016034430984895"
  location = "West Europe"
}
data "azurerm_subscription" "current" {
}
resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-231016034430984895"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-231016034430984895"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_network_manager_network_group" "import" {
  name               = azurerm_network_manager_network_group.test.name
  network_manager_id = azurerm_network_manager_network_group.test.network_manager_id
}
