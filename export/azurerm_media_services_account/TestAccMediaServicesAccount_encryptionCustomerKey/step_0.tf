

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-230915023800064792"
  location = "West Europe"
}

resource "azurerm_storage_account" "first" {
  name                     = "acctestsa1f83rx"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctest-uai-f83rx"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsaf83rx"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.first.id
    is_primary = true
  }
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.test.id]
  }
  encryption {
    type = "SystemKey"
  }

  tags = {
    environment = "staging"
  }
}
