
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810143140356927"
  location = "West Europe"
}
resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-230810143140356927"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "UltraSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  logical_sector_size  = 512
  zone                 = "1"
  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
