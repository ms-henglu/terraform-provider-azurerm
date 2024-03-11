

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311032225587142"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaolspl"
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
  name                = "acctesthdi-240311032225587142"
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

    edge_node {
      target_instance_count = 2
      vm_size               = "Standard_D3_V2"
      install_script_action {
        name = "script1"
        uri  = "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/8b3b3506159c370f032028664a84d604548b3e88/quickstarts/microsoft.hdinsight/hdinsight-linux-add-edge-node/scripts/EmptyNodeSetup.sh"
      }
    }
  }
}
