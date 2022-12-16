
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013235506875"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-221216013235506875"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
