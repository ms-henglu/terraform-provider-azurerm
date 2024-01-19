


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batchjob-240119024553045878"
  location = "west europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchtr6es"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool-240119024553045878"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 22.04"
  vm_size             = "Standard_A1"

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


resource "azurerm_batch_job" "test" {
  name          = "testaccbj-240119024553045878"
  batch_pool_id = azurerm_batch_pool.test.id
}


resource "azurerm_batch_job" "import" {
  name          = azurerm_batch_job.test.name
  batch_pool_id = azurerm_batch_job.test.batch_pool_id
}
