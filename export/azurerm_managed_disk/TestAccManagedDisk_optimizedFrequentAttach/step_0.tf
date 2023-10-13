
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043133425001"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                              = "acctestd-231013043133425001"
  location                          = azurerm_resource_group.test.location
  resource_group_name               = azurerm_resource_group.test.name
  storage_account_type              = "Standard_LRS"
  create_option                     = "Empty"
  disk_size_gb                      = "1"
  optimized_frequent_attach_enabled = true

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
