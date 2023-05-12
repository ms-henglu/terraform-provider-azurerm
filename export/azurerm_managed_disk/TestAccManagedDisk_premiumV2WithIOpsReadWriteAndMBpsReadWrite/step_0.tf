
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010404736615"
  location = "westeurope"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-230512010404736615"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "PremiumV2_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
  disk_iops_read_write = 3000
  disk_mbps_read_write = 125
}
