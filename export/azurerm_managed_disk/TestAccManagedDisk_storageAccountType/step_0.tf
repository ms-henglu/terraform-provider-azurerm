
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021734507266"
  location = "westeurope"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-240119021734507266"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "PremiumV2_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  logical_sector_size  = 512

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
