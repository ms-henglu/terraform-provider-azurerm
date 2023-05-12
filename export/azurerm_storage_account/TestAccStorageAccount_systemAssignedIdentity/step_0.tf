

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-230512011501349643"
  location = "West Europe"
}

resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-230512011501349643"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_storage_account" "test" {
  name                = "unlikely23exst2acctmu6mo"
  resource_group_name = azurerm_resource_group.test.name

  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }
}
