

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034015769414"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa8hksv"
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


resource "azurerm_virtual_network" "test" {
  name                = "acctestvirtnet231016034015769414"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsubnet231016034015769414"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_hdinsight_kafka_cluster" "test" {
  name                = "acctesthdi-231016034015769414"
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
    storage_resource_id  = azurerm_storage_account.test.id
    storage_container_id = azurerm_storage_container.test.id
    storage_account_key  = azurerm_storage_account.test.primary_access_key
    is_default           = true
  }

  network {
    connection_direction = "Outbound"
  }

  roles {
    head_node {
      vm_size            = "Standard_D3_V2"
      username           = "acctestusrvm"
      password           = "AccTestvdSC4daf986!"
      subnet_id          = azurerm_subnet.test.id
      virtual_network_id = azurerm_virtual_network.test.id
    }

    worker_node {
      vm_size                  = "Standard_D3_V2"
      username                 = "acctestusrvm"
      password                 = "AccTestvdSC4daf986!"
      target_instance_count    = 3
      number_of_disks_per_node = 2
      subnet_id                = azurerm_subnet.test.id
      virtual_network_id       = azurerm_virtual_network.test.id
    }

    zookeeper_node {
      vm_size            = "Standard_D3_V2"
      username           = "acctestusrvm"
      password           = "AccTestvdSC4daf986!"
      subnet_id          = azurerm_subnet.test.id
      virtual_network_id = azurerm_virtual_network.test.id
    }
  }

  tags = {
    Hello = "World"
  }
}
