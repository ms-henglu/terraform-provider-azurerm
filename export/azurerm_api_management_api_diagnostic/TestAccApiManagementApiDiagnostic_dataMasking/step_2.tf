

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825023946757633"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230825023946757633"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230825023946757633"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_logger" "test" {
  name                = "acctestapimnglogger-230825023946757633"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name

  application_insights {
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
  }
}

resource "azurerm_api_management_api" "test" {
  name                = "acctestAMA-230825023946757633"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  revision            = "1"
  display_name        = "Test API"
  path                = "test"
  protocols           = ["https"]

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }
}


resource "azurerm_api_management_api_diagnostic" "test" {
  identifier                = "applicationinsights"
  resource_group_name       = azurerm_resource_group.test.name
  api_management_name       = azurerm_api_management.test.name
  api_name                  = azurerm_api_management_api.test.name
  api_management_logger_id  = azurerm_api_management_logger.test.id
  sampling_percentage       = 1.0
  always_log_errors         = true
  log_client_ip             = true
  http_correlation_protocol = "W3C"
  verbosity                 = "verbose"

  backend_request {
    body_bytes     = 1
    headers_to_log = ["Host"]
  }

  backend_response {
    body_bytes     = 2
    headers_to_log = ["Content-Type"]
    data_masking {
      query_params {
        mode  = "Hide"
        value = "backend-Resp-Test-Update"
      }
    }
  }

  frontend_request {
    body_bytes     = 3
    headers_to_log = ["Accept"]
    data_masking {
      headers {
        mode  = "Mask"
        value = "frontend-Request-Header-Update"
      }
    }
  }

  frontend_response {
    body_bytes     = 4
    headers_to_log = ["Content-Length"]
    data_masking {
      query_params {
        mode  = "Hide"
        value = "frontend-Response-Test-Update"
      }

      query_params {
        mode  = "Mask"
        value = "frontend-Response-Test-Alt-Update"
      }

      query_params {
        mode  = "Mask"
        value = "frontend-Response-Test-Alt2-Update"
      }
      headers {
        mode  = "Mask"
        value = "frontend-Response-Header-Update"
      }
    }
  }
}
