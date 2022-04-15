
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220415030257337945"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                  = "acctestd-220415030257337945"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  storage_account_type  = "Standard_LRS"
  create_option         = "Empty"
  disk_size_gb          = "4"
  zone                  = "1"
  network_access_policy = "DenyAll"

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
