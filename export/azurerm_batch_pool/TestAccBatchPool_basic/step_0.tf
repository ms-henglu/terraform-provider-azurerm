
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-221111013134875761"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchon7tn"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoolon7tn"
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
