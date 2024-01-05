


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-240105064326591876"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-240105064326591876"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-240105064326591876"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-240105064326591876"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/22"]
}


resource "azurerm_network_manager_static_member" "test" {
  name                      = "acctest-nmsm-240105064326591876"
  network_group_id          = azurerm_network_manager_network_group.test.id
  target_virtual_network_id = azurerm_virtual_network.test.id
}


resource "azurerm_network_manager_static_member" "import" {
  name                      = azurerm_network_manager_static_member.test.name
  network_group_id          = azurerm_network_manager_static_member.test.network_group_id
  target_virtual_network_id = azurerm_network_manager_static_member.test.target_virtual_network_id
}
