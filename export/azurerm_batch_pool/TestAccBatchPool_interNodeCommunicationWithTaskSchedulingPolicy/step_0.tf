
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230313020756300560"
  location = "West Europe"
}
resource "azurerm_batch_account" "test" {
  name                          = "testaccbatchbhn0y"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  public_network_access_enabled = false
}
resource "azurerm_batch_pool" "test" {
  name                     = "testaccpoolbhn0y"
  resource_group_name      = azurerm_resource_group.test.name
  account_name             = azurerm_batch_account.test.name
  node_agent_sku_id        = "batch.node.ubuntu 18.04"
  vm_size                  = "Standard_A1"
  inter_node_communication = "Disabled"
  task_scheduling_policy {
    node_fill_type = "Pack"
  }
  fixed_scale {
    target_dedicated_nodes = 1
  }
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-lts"
    version   = "latest"
  }
}
