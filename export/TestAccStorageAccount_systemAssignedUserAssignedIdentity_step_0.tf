

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-220916012108363204"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-220916012108363204"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2accti6wz7"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
