

provider "azurerm" {
  features {}
}
provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-diskpool-230922061044328138"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-230922061044328138"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-230922061044328138"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.0.0/24"]
  delegation {
    name = "diskspool"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/read"]
      name    = "Microsoft.StoragePool/diskPools"
    }
  }
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctest-diskpool-230922061044328138"
  resource_group_name  = azurerm_resource_group.test.name
  location             = azurerm_resource_group.test.location
  create_option        = "Empty"
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 4
  max_shares           = 2
  zone                 = "1"
}

data "azuread_service_principal" "test" {
  display_name = "StoragePool Resource Provider"
}

locals {
  roles = ["Disk Pool Operator", "Virtual Machine Contributor"]
}

resource "azurerm_role_assignment" "test" {
  count                = length(local.roles)
  principal_id         = data.azuread_service_principal.test.id
  role_definition_name = local.roles[count.index]
  scope                = azurerm_managed_disk.test.id
}

resource "azurerm_disk_pool" "test" {
  name                = "acctest-diskpool-99xlf"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  zones               = ["1"]
  sku_name            = "Basic_B1"
  subnet_id           = azurerm_subnet.test.id
  tags = {
    "env" = "qa"
  }
}

resource "azurerm_disk_pool_managed_disk_attachment" "test" {
  depends_on      = [azurerm_role_assignment.test]
  disk_pool_id    = azurerm_disk_pool.test.id
  managed_disk_id = azurerm_managed_disk.test.id
}
