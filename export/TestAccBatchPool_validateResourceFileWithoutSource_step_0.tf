
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccbatch211001053505114794"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchbjbl6"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoolbjbl6"
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

  start_task {
    command_line         = "echo 'Hello World from $env'"
    max_task_retry_count = 1
    wait_for_success     = true

    environment = {
      env = "TEST"
      bu  = "Research&Dev"
    }

    user_identity {
      auto_user {
        elevation_level = "NonAdmin"
        scope           = "Task"
      }
    }

    resource_file {
      # no valid values for sources
      auto_storage_container_name = ""
      file_mode                   = "0770"
    }
  }
}
