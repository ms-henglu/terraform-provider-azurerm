
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221124181402022982"
  location = "West Europe"
}

resource "azurerm_managed_disk" "original" {
  name                 = "acctestmd-221124181402022982"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_snapshot" "first" {
  name                = "acctestss1_221124181402022982"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  create_option       = "Copy"
  source_uri          = azurerm_managed_disk.original.id
}

resource "azurerm_snapshot" "second" {
  name                = "acctestss2_221124181402022982"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  create_option       = "Copy"
  source_resource_id  = azurerm_snapshot.first.id
}
