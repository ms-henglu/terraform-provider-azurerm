
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccRG-batch-220506005441527666"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchyjt93"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoolyjt93"
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

  start_task {
    command_line       = "echo 'Hello World from $env'"
    wait_for_success   = true
    task_retry_maximum = 5
    common_environment_properties = {
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
      storage_container_url = "https://raw.githubusercontent.com/hashicorp/terraform-provider-azurerm/main/README.md"
      file_path             = "README.md"
    }
  }
}
