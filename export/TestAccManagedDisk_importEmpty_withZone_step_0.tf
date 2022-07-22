
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220722035002609660"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-220722035002609660"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
  zone                 = "1"

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
