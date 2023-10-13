
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043133424667"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-231013043133424667"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "UltraSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "4"
  disk_iops_read_only  = "102"
  disk_mbps_read_only  = "11"
  max_shares           = "2"
  zone                 = "1"

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
