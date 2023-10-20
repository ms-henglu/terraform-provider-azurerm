
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-databricks-231020040910092120"
  location = "West Europe"
}

resource "azurerm_virtual_network" "remote" {
  name                = "acctest-vnet-231020040910092120"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.1.0/24"]
  location            = azurerm_resource_group.test.location
}

resource "azurerm_databricks_workspace" "test" {
  name                = "acctest-ws-231020040910092120"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}


resource "azurerm_databricks_virtual_network_peering" "test" {
  name                = "acctest-231020040910092120"
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_databricks_workspace.test.id

  remote_address_space_prefixes = azurerm_virtual_network.remote.address_space
  remote_virtual_network_id     = azurerm_virtual_network.remote.id
}

resource "azurerm_virtual_network_peering" "remote" {
  name                      = "to-acctest-231020040910092120"
  resource_group_name       = azurerm_resource_group.test.name
  virtual_network_name      = azurerm_virtual_network.remote.name
  remote_virtual_network_id = azurerm_databricks_virtual_network_peering.test.virtual_network_id
}
