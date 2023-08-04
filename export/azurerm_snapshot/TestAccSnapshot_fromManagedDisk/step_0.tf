
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025626269084"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestmd-230804025626269084"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_snapshot" "test" {
  name                = "acctestss_230804025626269084"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  create_option       = "Copy"
  source_uri          = azurerm_managed_disk.test.id
}
