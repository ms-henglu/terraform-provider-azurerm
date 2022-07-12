

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy       = false
      purge_soft_deleted_keys_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-220712042900903737"
  location = "West Europe"
}


resource "azurerm_synapse_private_link_hub" "test" {
  name                = "acctestsw220712042900903737"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
