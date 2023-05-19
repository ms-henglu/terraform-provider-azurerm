

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230519074927786492"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-230519074927786492"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_iothub_device_update_account" "test" {
  name                = "acc-dua-722oh"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }
}
