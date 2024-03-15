

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-mysql-240315123615868588"
  location = "West Europe"
}


resource "azurerm_virtual_network" "test" {
  name                = "acctest-vn-240315123615868588"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-sn-240315123615868588"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "test" {
  name                = "acc240315123615868588.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "test" {
  name                  = "acctestVnetZone240315123615868588.com"
  private_dns_zone_name = azurerm_private_dns_zone.test.name
  virtual_network_id    = azurerm_virtual_network.test.id
  resource_group_name   = azurerm_resource_group.test.name

  depends_on = [azurerm_subnet.test]
}

resource "azurerm_mysql_flexible_server" "test" {
  name                         = "acctest-fs-240315123615868588"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  administrator_login          = "adminTerraform"
  administrator_password       = "123wsxQAZ"
  zone                         = "1"
  version                      = "8.0.21"
  backup_retention_days        = 10
  geo_redundant_backup_enabled = false

  storage {
    size_gb            = 32
    iops               = 400
    auto_grow_enabled  = false
    io_scaling_enabled = false
  }

  delegated_subnet_id = azurerm_subnet.test.id
  private_dns_zone_id = azurerm_private_dns_zone.test.id
  sku_name            = "GP_Standard_D4ds_v4"

  maintenance_window {
    day_of_week  = 0
    start_hour   = 8
    start_minute = 0
  }

  tags = {
    ENV = "Stage"
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.test]
}
