


provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-amlfs-240105061645412161"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-240105061645412161"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-240105061645412161"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_managed_lustre_file_system" "test" {
  name                   = "acctest-amlfs-240105061645412161"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  sku_name               = "AMLFS-Durable-Premium-250"
  subnet_id              = azurerm_subnet.test.id
  storage_capacity_in_tb = 8
  zones                  = ["2"]

  maintenance_window {
    day_of_week        = "Friday"
    time_of_day_in_utc = "22:00"
  }
}


resource "azurerm_managed_lustre_file_system" "import" {
  name                   = azurerm_managed_lustre_file_system.test.name
  resource_group_name    = azurerm_managed_lustre_file_system.test.resource_group_name
  location               = azurerm_managed_lustre_file_system.test.location
  sku_name               = azurerm_managed_lustre_file_system.test.sku_name
  subnet_id              = azurerm_managed_lustre_file_system.test.subnet_id
  storage_capacity_in_tb = azurerm_managed_lustre_file_system.test.storage_capacity_in_tb
  zones                  = azurerm_managed_lustre_file_system.test.zones

  maintenance_window {
    day_of_week        = "Friday"
    time_of_day_in_utc = "22:00"
  }
}
