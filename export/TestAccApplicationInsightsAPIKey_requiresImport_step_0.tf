
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015013855908688"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-211015013855908688"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_api_key" "test" {
  name                    = "acctestappinsightsapikey-211015013855908688"
  application_insights_id = azurerm_application_insights.test.id
  read_permissions        = []
  write_permissions       = ["annotations"]
}
