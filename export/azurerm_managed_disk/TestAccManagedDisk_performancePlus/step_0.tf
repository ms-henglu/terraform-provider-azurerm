
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033603995686"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                     = "acctestd-231016033603995686"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  storage_account_type     = "Premium_LRS"
  create_option            = "Empty"
  disk_size_gb             = "1024"
  performance_plus_enabled = true
  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
