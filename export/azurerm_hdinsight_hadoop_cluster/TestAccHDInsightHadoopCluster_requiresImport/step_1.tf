


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043539821811"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsall8e7"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "acctest"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}


resource "azurerm_hdinsight_hadoop_cluster" "test" {
  name                = "acctesthdi-231013043539821811"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_version     = "4.0"
  tier                = "Standard"

  component_version {
    hadoop = "3.1"
  }

  gateway {
    username = "acctestusrgw"
    password = "TerrAform123!"
  }

  storage_account {
    storage_container_id = azurerm_storage_container.test.id
    storage_account_key  = azurerm_storage_account.test.primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size  = "Standard_D3_V2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }

    worker_node {
      vm_size               = "Standard_D4_V2"
      username              = "acctestusrvm"
      password              = "AccTestvdSC4daf986!"
      target_instance_count = 2
    }

    zookeeper_node {
      vm_size  = "Standard_D3_V2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }
  }
}


resource "azurerm_hdinsight_hadoop_cluster" "import" {
  name                = azurerm_hdinsight_hadoop_cluster.test.name
  resource_group_name = azurerm_hdinsight_hadoop_cluster.test.resource_group_name
  location            = azurerm_hdinsight_hadoop_cluster.test.location
  cluster_version     = azurerm_hdinsight_hadoop_cluster.test.cluster_version
  tier                = azurerm_hdinsight_hadoop_cluster.test.tier
  dynamic "component_version" {
    for_each = azurerm_hdinsight_hadoop_cluster.test.component_version
    content {
      hadoop = component_version.value.hadoop
    }
  }
  dynamic "gateway" {
    for_each = azurerm_hdinsight_hadoop_cluster.test.gateway
    content {
      password = gateway.value.password
      username = gateway.value.username
    }
  }
  dynamic "storage_account" {
    for_each = azurerm_hdinsight_hadoop_cluster.test.storage_account
    content {
      is_default           = storage_account.value.is_default
      storage_account_key  = storage_account.value.storage_account_key
      storage_container_id = storage_account.value.storage_container_id
    }
  }
  dynamic "roles" {
    for_each = azurerm_hdinsight_hadoop_cluster.test.roles
    content {
      dynamic "edge_node" {
        for_each = lookup(roles.value, "edge_node", [])
        content {
          target_instance_count = edge_node.value.target_instance_count
          vm_size               = edge_node.value.vm_size

          dynamic "install_script_action" {
            for_each = lookup(edge_node.value, "install_script_action", [])
            content {
              name = install_script_action.value.name
              uri  = install_script_action.value.uri
            }
          }
        }
      }

      dynamic "head_node" {
        for_each = lookup(roles.value, "head_node", [])
        content {
          password = lookup(head_node.value, "password", null)
          username = head_node.value.username
          vm_size  = head_node.value.vm_size
        }
      }

      dynamic "worker_node" {
        for_each = lookup(roles.value, "worker_node", [])
        content {
          password              = lookup(worker_node.value, "password", null)
          target_instance_count = worker_node.value.target_instance_count
          username              = worker_node.value.username
          vm_size               = worker_node.value.vm_size
        }
      }

      dynamic "zookeeper_node" {
        for_each = lookup(roles.value, "zookeeper_node", [])
        content {
          password = lookup(zookeeper_node.value, "password", null)
          username = zookeeper_node.value.username
          vm_size  = zookeeper_node.value.vm_size
        }
      }
    }
  }
}
