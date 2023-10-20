


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batchjob-231020040628862969"
  location = "west europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchnqnim"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool-231020040628862969"
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
  name          = "testaccbj-231020040628862969"
  batch_pool_id = azurerm_batch_pool.test.id
}


resource "azurerm_batch_job" "import" {
  name          = azurerm_batch_job.test.name
  batch_pool_id = azurerm_batch_job.test.batch_pool_id
}
