

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230616075105050297"
  location = "West Europe"
}

resource "azurerm_storage_account" "first" {
  name                     = "acctestsa1jvjj0"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_media_services_account" "test" {
  name                = "acctestmsajvjj0"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.first.id
    is_primary = true
  }

  tags = {
    environment = "staging"
  }

  identity {
    type = "SystemAssigned"
  }

  key_delivery_access_control {
    default_action = "Deny"
    ip_allow_list  = ["0.0.0.0/0"]
  }
}
