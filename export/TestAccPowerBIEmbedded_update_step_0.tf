

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-powerbi-220204060452706258"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}


resource "azurerm_powerbi_embedded" "test" {
  name                = "acctestpowerbi220204060452706258"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "A1"
  administrators      = [data.azurerm_client_config.test.object_id]
}
