
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220204055814358935"
  location = "West Europe"
}

resource "azurerm_disk_access" "test" {
  name                = "accda220204055814358935"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    environment = "staging"
  }
}

resource "azurerm_managed_disk" "test" {
  name                  = "acctestd-220204055814358935"
  location              = azurerm_resource_group.test.location
  resource_group_name   = azurerm_resource_group.test.name
  storage_account_type  = "Standard_LRS"
  create_option         = "Empty"
  disk_size_gb          = "4"
  zones                 = ["1"]
  network_access_policy = "AllowPrivate"
  disk_access_id        = azurerm_disk_access.test.id

  tags = {
    environment = "acctest"
    cost-center = "ops"
  }
}
