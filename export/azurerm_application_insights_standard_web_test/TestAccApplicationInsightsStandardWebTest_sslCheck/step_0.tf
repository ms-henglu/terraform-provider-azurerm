
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-230825024002816092"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230825024002816092"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_standard_web_test" "test" {
  name                    = "acctestappinsightswebtests-230825024002816092"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  geo_locations           = ["us-tx-sn1-azr"]

  request {
    url = "https://microsoft.com"
  }
  validation_rules {
    ssl_check_enabled = true
  }

  lifecycle {
    ignore_changes = ["tags"]
  }
}
