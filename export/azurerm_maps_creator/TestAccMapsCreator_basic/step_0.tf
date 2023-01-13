
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181403486222"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230113181403486222"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}


resource "azurerm_maps_creator" "test" {
  name            = "accMapsCreator-230113181403486222"
  maps_account_id = azurerm_maps_account.test.id
  location        = "West Europe"
  storage_units   = 1
}
