

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010404763698"
  location = "West Europe"
}

resource "azurerm_managed_disk" "test" {
  name                 = "acctestmd-230512010404763698"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_snapshot" "test" {
  name                = "acctestss_230512010404763698"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  create_option       = "Copy"
  source_uri          = azurerm_managed_disk.test.id
}


resource "azurerm_snapshot" "import" {
  name                = azurerm_snapshot.test.name
  location            = azurerm_snapshot.test.location
  resource_group_name = azurerm_snapshot.test.resource_group_name
  create_option       = azurerm_snapshot.test.create_option
  source_uri          = azurerm_snapshot.test.source_uri
}
