
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-240119021445729715"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-240119021445729715"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_standard_web_test" "test" {
  name                    = "acctestappinsightswebtests-240119021445729715"
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

  validation_rules {
    expected_status_code = 200

    ssl_cert_remaining_lifetime = 20
    ssl_check_enabled           = true

    content {
      content_match      = "Unknown"
      ignore_case        = true
      pass_if_text_found = true
    }
  }
}
