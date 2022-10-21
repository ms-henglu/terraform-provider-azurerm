
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021034330107722"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-221021034330107722"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}


resource "azurerm_maps_creator" "test" {
  name            = "accMapsCreator-221021034330107722"
  maps_account_id = azurerm_maps_account.test.id
  location        = "West Europe"
  storage_units   = 1

  tags = {
    ENV = "Test"
  }
}
