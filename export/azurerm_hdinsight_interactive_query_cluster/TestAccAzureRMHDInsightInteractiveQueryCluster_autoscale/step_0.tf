

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043539833449"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsazdeir"
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
  name                = "acctesthdi-231013043539833449"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_version     = "4.0"
  tier                = "Standard"
  component_version {
    interactive_hive = "3.1"
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
      vm_size  = "Standard_D13_V2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }
    worker_node {
      vm_size               = "Standard_D14_V2"
      username              = "acctestusrvm"
      password              = "AccTestvdSC4daf986!"
      target_instance_count = 2
      autoscale {
        recurrence {
          timezone = "Pacific Standard Time"
          schedule {
            days                  = ["Monday"]
            time                  = "10:00"
            target_instance_count = 5
          }
          schedule {
            days                  = ["Saturday", "Sunday"]
            time                  = "10:00"
            target_instance_count = 3
          }
        }
      }
    }
    zookeeper_node {
      vm_size  = "Standard_A4_V2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }
  }
}
