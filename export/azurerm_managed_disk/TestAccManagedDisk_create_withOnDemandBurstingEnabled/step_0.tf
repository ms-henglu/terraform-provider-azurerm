
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414020945113864"
  location = "West Europe"
}
resource "azurerm_managed_disk" "test" {
  name                       = "acctestd-230414020945113864"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  storage_account_type       = "Premium_LRS"
  create_option              = "Empty"
  disk_size_gb               = "1024"
  on_demand_bursting_enabled = true
  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
