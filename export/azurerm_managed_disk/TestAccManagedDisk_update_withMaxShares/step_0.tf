
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043133422317"
  location = "West Europe"
}
resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-231013043133422317"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
  max_shares           = 2
  zone                 = "1"
  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
