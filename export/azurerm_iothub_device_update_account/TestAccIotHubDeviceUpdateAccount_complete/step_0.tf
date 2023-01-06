

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230106031537405826"
  location = "West Europe"
}


resource "azurerm_user_assigned_identity" "test" {
  name                = "acctestUAI-230106031537405826"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_iothub_device_update_account" "test" {
  name                          = "acc-dua-ic49j"
  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  public_network_access_enabled = false
  sku                           = "Free"

  identity {
    type = "SystemAssigned, UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.test.id,
    ]
  }

  tags = {
    environment = "AccTest"
  }
}
