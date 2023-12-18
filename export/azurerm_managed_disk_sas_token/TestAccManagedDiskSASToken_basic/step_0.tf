
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-revokedisk-231218071435456050"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestsads1d8qb"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
}

resource "azurerm_managed_disk_sas_token" "test" {
  managed_disk_id     = azurerm_managed_disk.test.id
  duration_in_seconds = 300
  access_level        = "Read"
}
