


provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-240119025952425963"
  location = "West Europe"
}


resource "azurerm_synapse_private_link_hub" "test" {
  name                = "acctestsw240119025952425963"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}


resource "azurerm_synapse_private_link_hub" "import" {
  name                = azurerm_synapse_private_link_hub.test.name
  resource_group_name = azurerm_synapse_private_link_hub.test.resource_group_name
  location            = azurerm_synapse_private_link_hub.test.location
}
