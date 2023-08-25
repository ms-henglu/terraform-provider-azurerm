


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batchjob-230825024120205779"
  location = "west europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchsd8hj"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool-230825024120205779"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 18.04"
  vm_size             = "Standard_A1"

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


resource "azurerm_batch_job" "test" {
  name          = "testaccbj-230825024120205779"
  batch_pool_id = azurerm_batch_pool.test.id
}


resource "azurerm_batch_job" "import" {
  name          = azurerm_batch_job.test.name
  batch_pool_id = azurerm_batch_job.test.batch_pool_id
}
