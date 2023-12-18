
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-231218071150975673"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-231218071150975673"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_application_insights_standard_web_test" "test" {
  name                    = "acctestappinsightswebtests-231218071150975673"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  application_insights_id = azurerm_application_insights.test.id
  frequency               = 900
  timeout                 = 120
  enabled                 = true
  description             = "web_test"
  retry_enabled           = true
  tags = {
    ENV = "web_test"
  }
  geo_locations = ["us-tx-sn1-azr", "us-il-ch1-azr"]

  request {
    follow_redirects_enabled         = true
    http_verb                        = "POST"
    parse_dependent_requests_enabled = true
    url                              = "https://microsoft.com"

    body = "{\"test\": \"value\"}"

    header {
      name  = "x-header"
      value = "testheader"
    }
    header {
      name  = "x-header-2"
      value = "testheaderupdated"
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

  lifecycle {
    ignore_changes = ["tags"]
  }
}
