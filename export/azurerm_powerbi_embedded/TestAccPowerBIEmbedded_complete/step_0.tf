

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-powerbi-221202040237405358"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}


resource "azurerm_powerbi_embedded" "test" {
  name                = "acctestpowerbi221202040237405358"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "A2"
  administrators      = [data.azurerm_client_config.test.object_id]

  tags = {
    ENV = "Test"
  }
}
