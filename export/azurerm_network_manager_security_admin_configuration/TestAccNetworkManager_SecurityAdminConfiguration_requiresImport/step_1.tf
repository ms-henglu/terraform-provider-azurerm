


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-network-manager-240315123704044758"
  location = "West Europe"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "test" {
  name                = "acctest-nm-240315123704044758"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["SecurityAdmin"]
}

resource "azurerm_network_manager_network_group" "test" {
  name               = "acctest-nmng-240315123704044758"
  network_manager_id = azurerm_network_manager.test.id
}

resource "azurerm_virtual_network" "test" {
  name                    = "acctest-vnet-240315123704044758"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  address_space           = ["10.0.0.0/16"]
  flow_timeout_in_minutes = 10
}



resource "azurerm_network_manager_security_admin_configuration" "test" {
  name               = "acctest-nmsac-240315123704044758"
  network_manager_id = azurerm_network_manager.test.id
}


resource "azurerm_network_manager_security_admin_configuration" "import" {
  name               = azurerm_network_manager_security_admin_configuration.test.name
  network_manager_id = azurerm_network_manager_security_admin_configuration.test.network_manager_id
}
