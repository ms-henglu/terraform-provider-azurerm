
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-230407022949574524"
  location = "West Europe"
}
resource "azurerm_batch_account" "test" {
  name                          = "testaccbatcht8trp"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  public_network_access_enabled = false
}
resource "azurerm_batch_pool" "test" {
  name                     = "testaccpoolt8trp"
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
