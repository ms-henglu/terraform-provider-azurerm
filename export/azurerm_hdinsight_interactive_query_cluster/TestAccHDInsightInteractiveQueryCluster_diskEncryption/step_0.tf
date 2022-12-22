

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034739172952"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsavehix"
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


resource "azurerm_hdinsight_interactive_query_cluster" "test" {
  name                = "acctesthdi-221222034739172952"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_version     = "4.0"
  tier                = "Standard"
  tls_min_version     = "1.2"

  component_version {
    interactive_hive = "3.1"
  }

  disk_encryption {
    encryption_at_host_enabled = true
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
      vm_size  = "Standard_D8a_V4"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }

    worker_node {
      vm_size               = "Standard_D16a_V4"
      username              = "acctestusrvm"
      password              = "AccTestvdSC4daf986!"
      target_instance_count = 2
    }

    zookeeper_node {
      vm_size  = "Standard_DS2_V2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }
  }
}
