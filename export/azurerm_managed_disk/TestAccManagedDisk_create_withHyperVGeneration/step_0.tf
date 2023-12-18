
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071435531556"
  location = "West Europe"
}
resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-231218071435531556"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1024"
  zone                 = "1"
  hyper_v_generation   = "V2"
  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
