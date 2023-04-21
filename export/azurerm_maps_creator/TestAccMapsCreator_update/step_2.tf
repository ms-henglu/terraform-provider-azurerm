
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421022515521972"
  location = "West Europe"
}

resource "azurerm_maps_account" "test" {
  name                = "accMapsAccount-230421022515521972"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "G2"
}


resource "azurerm_maps_creator" "test" {
  name            = "accMapsCreator-230421022515521972"
  maps_account_id = azurerm_maps_account.test.id
  location        = "West Europe"
  storage_units   = 2

  tags = {
    ENV  = "Test",
    ENV2 = "Test2"
  }
}
