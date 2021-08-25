

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-210825030253491380"
  location = "West Europe"
}


resource "azurerm_synapse_private_link_hub" "test" {
  name                = "acctestsw210825030253491380"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
