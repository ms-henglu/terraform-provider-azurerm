

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218071435539530"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-231218071435539530"
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


resource "azurerm_managed_disk" "import" {
  name                 = azurerm_managed_disk.test.name
  location             = azurerm_managed_disk.test.location
  resource_group_name  = azurerm_managed_disk.test.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
