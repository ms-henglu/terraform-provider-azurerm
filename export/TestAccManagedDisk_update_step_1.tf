
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220429065303861758"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-220429065303861758"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "2"

  tags = {
    environment = "acctest"
  }
}
