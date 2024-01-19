
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-240119024553055638"
  location = "West Europe"
}
resource "azurerm_batch_account" "test" {
  name                          = "testaccbatchx8lvr"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  public_network_access_enabled = false
}
resource "azurerm_batch_pool" "test" {
  name                     = "testaccpoolx8lvr"
  resource_group_name      = azurerm_resource_group.test.name
  account_name             = azurerm_batch_account.test.name
  node_agent_sku_id        = "batch.node.ubuntu 22.04"
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
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
