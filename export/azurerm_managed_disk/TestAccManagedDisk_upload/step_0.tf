
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230630032848799969"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestd-230630032848799969"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  create_option        = "Upload"
  storage_account_type = "Standard_LRS"
  upload_size_bytes    = 21475885568
}
