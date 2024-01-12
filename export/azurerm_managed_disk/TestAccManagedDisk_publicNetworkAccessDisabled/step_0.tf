
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224137921285"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                          = "acctestd-240112224137921285"
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  storage_account_type          = "Standard_LRS"
  create_option                 = "Empty"
  disk_size_gb                  = "4"
  public_network_access_enabled = false
}
