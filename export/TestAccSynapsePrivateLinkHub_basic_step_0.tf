

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-synapse-211015014924801969"
  location = "West Europe"
}


resource "azurerm_synapse_private_link_hub" "test" {
  name                = "acctestsw211015014924801969"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
