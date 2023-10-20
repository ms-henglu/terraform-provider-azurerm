

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-batch-231020040628860469"
  location = "West Europe"
}
resource "azurerm_network_security_group" "test" {
  name                = "testnsg-batch-83xey"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
resource "azurerm_virtual_network" "test" {
  name                = "testvn-batch-83xey"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}
resource "azurerm_subnet" "testsubnet" {
  name                 = "testsn-83xey"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = azurerm_subnet.testsubnet.id
  network_security_group_id = azurerm_network_security_group.test.id
}


resource "azurerm_batch_account" "test" {
  name                = "testaccbatch83xey"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpool83xey"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 20.04"
  vm_size             = "Standard_A1"

  fixed_scale {
    target_dedicated_nodes = 1
  }

  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "20-04-lts"
    version   = "latest"
  }

  container_configuration {
    type                  = "DockerCompatible"
    container_image_names = ["centos7"]
    container_registries {
      registry_server = "myContainerRegistry.azurecr.io"
      user_name       = "myUserName"
      password        = "myPassword"
    }
  }

  start_task {
    command_line       = "echo 'Hello World from $env'"
    wait_for_success   = true
    task_retry_maximum = 5
    common_environment_properties = {
      env = "TEST"
      bu  = "Research&Dev"
    }

    container {
      run_options = "cat /proc/cpuinfo"
      image_name  = "centos7"
      registry {
        registry_server = "myContainerRegistry.azurecr.io"
        user_name       = "myUserName"
        password        = "myPassword"
      }
      working_directory = "ContainerImageDefault"
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
