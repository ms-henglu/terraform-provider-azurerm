
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034403178101"
  location = "West Europe"
}
resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-221222034403178101"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1024"
  max_shares           = 5
  zone                 = "1"
  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
