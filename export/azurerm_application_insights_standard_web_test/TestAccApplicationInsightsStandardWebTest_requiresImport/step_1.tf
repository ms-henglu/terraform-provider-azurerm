

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-240112033800240273"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-240112033800240273"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_standard_web_test" "test" {
  name                    = "acctestappinsightswebtests-240112033800240273"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  geo_locations           = ["us-tx-sn1-azr"]

  request {
    follow_redirects_enabled         = false
    http_verb                        = "GET"
    parse_dependent_requests_enabled = false
    url                              = "http://microsoft.com"

    header {
      name  = "x-header"
      value = "testheader"
    }
    header {
      name  = "x-header-2"
      value = "testheader2"
    }
  }
}


resource "azurerm_application_insights_standard_web_test" "import" {
  name                    = azurerm_application_insights_standard_web_test.test.name
  location                = azurerm_application_insights_standard_web_test.test.location
  resource_group_name     = azurerm_application_insights_standard_web_test.test.resource_group_name
  application_insights_id = azurerm_application_insights_standard_web_test.test.application_insights_id
  geo_locations           = azurerm_application_insights_standard_web_test.test.geo_locations
  request {
    follow_redirects_enabled         = azurerm_application_insights_standard_web_test.test.request.0.follow_redirects_enabled
    http_verb                        = azurerm_application_insights_standard_web_test.test.request.0.http_verb
    parse_dependent_requests_enabled = azurerm_application_insights_standard_web_test.test.request.0.parse_dependent_requests_enabled
    url                              = azurerm_application_insights_standard_web_test.test.request.0.url

    header {
      name  = azurerm_application_insights_standard_web_test.test.request.0.header.0.name
      value = azurerm_application_insights_standard_web_test.test.request.0.header.0.value
    }

    header {
      name  = azurerm_application_insights_standard_web_test.test.request.0.header.1.name
      value = azurerm_application_insights_standard_web_test.test.request.0.header.1.value
    }
  }
}
