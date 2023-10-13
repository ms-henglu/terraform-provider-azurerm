

provider "azurerm" {
  features {}
}
provider "azuread" {}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-diskspool-231013043409157661"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-231013043409157661"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-subnet-231013043409157661"
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

locals {
  disk_count = 1
}

resource "azurerm_managed_disk" "test" {
  count                = local.disk_count
  name                 = "acctest-diskspool-231013043409157661${count.index}"
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
// DO NOT attempt to use mod operator to make two assignments into one because we must use "%" to escape percent sign and that will break terrafmt
resource "azurerm_role_assignment" "disk_pool_operator" {
  count                = local.disk_count
  principal_id         = data.azuread_service_principal.test.id
  role_definition_name = "Disk Pool Operator"
  scope                = azurerm_managed_disk.test[count.index].id
}

resource "azurerm_role_assignment" "vm_contributor" {
  count                = local.disk_count
  principal_id         = data.azuread_service_principal.test.id
  role_definition_name = "Virtual Machine Contributor"
  scope                = azurerm_managed_disk.test[count.index].id
}

resource "azurerm_disk_pool" "test" {
  name                = "acctest-diskspool-mtlcw"
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
  count           = local.disk_count
  depends_on      = [azurerm_role_assignment.disk_pool_operator, azurerm_role_assignment.vm_contributor]
  disk_pool_id    = azurerm_disk_pool.test.id
  managed_disk_id = azurerm_managed_disk.test[count.index].id
}

resource "azurerm_disk_pool_iscsi_target" "test" {
  depends_on    = [azurerm_disk_pool_managed_disk_attachment.test]
  name          = "acctest-diskpool-mtlcw"
  acl_mode      = "Dynamic"
  disks_pool_id = azurerm_disk_pool.test.id
  target_iqn    = "iqn.2021-11.com.microsoft:test"
}


resource "azurerm_disk_pool_iscsi_target_lun" "test" {
  iscsi_target_id                      = azurerm_disk_pool_iscsi_target.test.id
  disk_pool_managed_disk_attachment_id = azurerm_disk_pool_managed_disk_attachment.test[0].id
  name                                 = "test-0"
}
