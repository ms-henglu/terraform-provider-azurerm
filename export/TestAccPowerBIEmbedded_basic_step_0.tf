

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-powerbi-220121044846154632"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}


resource "azurerm_powerbi_embedded" "test" {
  name                = "acctestpowerbi220121044846154632"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "A1"
  administrators      = [data.azurerm_client_config.test.object_id]
}
