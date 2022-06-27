
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "testaccbatch220627134251958014"
  location = "West Europe"
}

resource "azurerm_container_registry" "test" {
  name                = "testregistryfmv2c"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Basic"
}

resource "azurerm_batch_account" "test" {
  name                = "testaccbatchfmv2c"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_batch_pool" "test" {
  name                = "testaccpoolfmv2c"
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_batch_account.test.name
  node_agent_sku_id   = "batch.node.ubuntu 16.04"
  vm_size             = "Standard_A1"

  fixed_scale {
    target_dedicated_nodes = 1
  }

  storage_image_reference {
    publisher = "microsoft-azure-batch"
    offer     = "ubuntu-server-container"
    sku       = "16-04-lts"
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
}
