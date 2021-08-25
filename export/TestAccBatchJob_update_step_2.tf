

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batchjob-210825044521988255"
  location = "west europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchb137m"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool-210825044521988255"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 16.04"
  vm_size             = "Standard_A1"

  fixed_scale {
    target_dedicated_nodes = 1
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }
}


resource "azurerm_batch_job" "test" {
  name               = "testaccbj-210825044521988255"
  batch_pool_id      = azurerm_batch_pool.test.id
  priority           = 2
  task_retry_maximum = -1
}
