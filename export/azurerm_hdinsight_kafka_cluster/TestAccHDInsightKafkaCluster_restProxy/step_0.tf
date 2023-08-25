

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024628101145"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsauznj4"
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


provider "azuread" {}

resource "azuread_group" "test" {
  display_name     = "acctesthdi-230825024628101145"
  security_enabled = true
}

resource "azurerm_hdinsight_kafka_cluster" "test" {
  name                = "acctesthdi-230825024628101145"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cluster_version     = "4.0"
  tier                = "Standard"

  component_version {
    kafka = "2.1"
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
      vm_size                  = "Standard_D3_V2"
      username                 = "acctestusrvm"
      password                 = "AccTestvdSC4daf986!"
      target_instance_count    = 3
      number_of_disks_per_node = 2
    }

    zookeeper_node {
      vm_size  = "Standard_D3_V2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }

    kafka_management_node {
      vm_size  = "Standard_D4_V2"
      username = "acctestusrvm"
      password = "AccTestvdSC4daf986!"
    }
  }

  rest_proxy {
    security_group_id   = azuread_group.test.id
    security_group_name = azuread_group.test.display_name
  }
}
