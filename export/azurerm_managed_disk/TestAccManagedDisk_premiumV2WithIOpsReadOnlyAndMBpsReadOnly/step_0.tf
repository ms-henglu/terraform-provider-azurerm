
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024707408076"
  location = "westeurope"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-240119024707408076"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "PremiumV2_LRS"
  create_option        = "Empty"
  disk_size_gb         = 256
  disk_iops_read_only  = 3000
  disk_mbps_read_only  = 125
  max_shares           = 5
}
