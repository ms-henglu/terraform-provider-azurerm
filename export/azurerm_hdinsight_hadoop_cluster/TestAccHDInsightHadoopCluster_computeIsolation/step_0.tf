

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105063922195379"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsat0jtq"
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
  name                = "acctesthdihadoop-240105063922195379"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_version     = "4.0"
  tier                = "Premium"

  component_version {
    hadoop = "3.1"
  }

  compute_isolation {
    compute_isolation_enabled = true
  }

  gateway {
    username = "sshuser"
    password = "TerrAform123!"
  }

  storage_account {
    storage_container_id = azurerm_storage_container.test.id
    storage_account_key  = azurerm_storage_account.test.primary_access_key
    is_default           = true
  }

  roles {
    head_node {
      vm_size  = "Standard_F72s_V2"
      username = "sshuser"
      password = "TerrAform123!"
    }

    worker_node {
      vm_size               = "Standard_F72s_V2"
      username              = "sshuser"
      password              = "TerrAform123!"
      target_instance_count = 1
    }

    zookeeper_node {
      vm_size  = "Standard_F72s_V2"
      username = "sshuser"
      password = "TerrAform123!"
    }
  }
}
