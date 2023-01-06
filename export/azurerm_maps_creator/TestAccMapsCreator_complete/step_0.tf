
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230106031701216008"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230106031701216008"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}


resource "azurerm_maps_creator" "test" {
  name            = "accMapsCreator-230106031701216008"
  maps_account_id = azurerm_maps_account.test.id
  location        = "West Europe"
  storage_units   = 1

  tags = {
    ENV = "Test"
  }
}
