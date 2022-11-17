
			
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221117231148814449"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221117231148814449"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}


resource "azurerm_maps_creator" "test" {
  name            = "accMapsCreator-221117231148814449"
  maps_account_id = azurerm_maps_account.test.id
  location        = "West Europe"
  storage_units   = 1
}


resource "azurerm_maps_creator" "import" {
  name            = azurerm_maps_creator.test.name
  maps_account_id = azurerm_maps_account.test.id
  location        = "West Europe"
  storage_units   = 1
}
