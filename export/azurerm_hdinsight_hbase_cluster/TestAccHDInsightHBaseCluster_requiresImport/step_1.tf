


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060855687729"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsakw3tg"
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


resource "azurerm_hdinsight_hbase_cluster" "test" {
  name                = "acctesthdi-240105060855687729"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_version     = "4.0"
  tier                = "Standard"

  component_version {
    hbase = "2.1"
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
      vm_size               = "Standard_D3_V2"
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


resource "azurerm_hdinsight_hbase_cluster" "import" {
  name                = azurerm_hdinsight_hbase_cluster.test.name
  resource_group_name = azurerm_hdinsight_hbase_cluster.test.resource_group_name
  location            = azurerm_hdinsight_hbase_cluster.test.location
  cluster_version     = azurerm_hdinsight_hbase_cluster.test.cluster_version
  tier                = azurerm_hdinsight_hbase_cluster.test.tier
  dynamic "component_version" {
    for_each = azurerm_hdinsight_hbase_cluster.test.component_version
    content {
      hbase = component_version.value.hbase
    }
  }
  dynamic "gateway" {
    for_each = azurerm_hdinsight_hbase_cluster.test.gateway
    content {
      password = gateway.value.password
      username = gateway.value.username
    }
  }
  dynamic "storage_account" {
    for_each = azurerm_hdinsight_hbase_cluster.test.storage_account
    content {
      is_default           = storage_account.value.is_default
      storage_account_key  = storage_account.value.storage_account_key
      storage_container_id = storage_account.value.storage_container_id
    }
  }
  dynamic "roles" {
    for_each = azurerm_hdinsight_hbase_cluster.test.roles
    content {
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
