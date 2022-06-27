

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220627122426679944"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatch2r1ey"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool2r1ey"
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


resource "azurerm_batch_pool" "import" {
  name                = azurerm_batch_pool.test.name
  resource_group_name = azurerm_batch_pool.test.resource_group_name
  account_name        = azurerm_batch_pool.test.account_name
  node_agent_sku_id   = azurerm_batch_pool.test.node_agent_sku_id
  vm_size             = azurerm_batch_pool.test.vm_size

  fixed_scale {
    target_dedicated_nodes = azurerm_batch_pool.test.fixed_scale[0].target_dedicated_nodes
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }
}
