
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023108517018"
  location = "West Europe"
}

resource "azurerm_managed_disk" "original" {
  name                 = "acctestmd-230915023108517018"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_snapshot" "first" {
  name                = "acctestss1_230915023108517018"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  create_option       = "Copy"
  source_uri          = azurerm_managed_disk.original.id
}

resource "azurerm_snapshot" "second" {
  name                = "acctestss2_230915023108517018"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  create_option       = "Copy"
  source_resource_id  = azurerm_snapshot.first.id
}
