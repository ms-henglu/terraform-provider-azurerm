
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-230922060658193382"
  location = "West Europe"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatch3pbox"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool3pbox"
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
      http_url  = "https://raw.githubusercontent.com/hashicorp/terraform-provider-azurerm/main/README.md"
      file_path = "README.md"
    }
  }
}
