

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112223839715031"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-240112223839715031"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240112223839715031"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_logger" "test" {
  name                = "acctestapimnglogger-240112223839715031"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name

  application_insights {
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
  }
}


resource "azurerm_api_management_diagnostic" "test" {
  identifier                = "applicationinsights"
  resource_group_name       = azurerm_resource_group.test.name
  api_management_name       = azurerm_api_management.test.name
  api_management_logger_id  = azurerm_api_management_logger.test.id
  sampling_percentage       = 11.1
  always_log_errors         = false
  log_client_ip             = false
  http_correlation_protocol = "Legacy"
  verbosity                 = "error"

  frontend_request {
    body_bytes     = 100
    headers_to_log = ["Accept"]
    data_masking {
      query_params {
        mode  = "Hide"
        value = "backend-Request-Test"
      }
      headers {
        mode  = "Mask"
        value = "backend-Request-Header"
      }
    }
  }

  frontend_response {
    body_bytes     = 1000
    headers_to_log = ["Content-Length"]
    data_masking {
      query_params {
        mode  = "Hide"
        value = "backend-Request-Test"
      }
      headers {
        mode  = "Mask"
        value = "backend-Request-Header"
      }
    }
  }

  backend_request {
    body_bytes     = 1
    headers_to_log = ["Host", "Content-Encoding"]
    data_masking {
      query_params {
        mode  = "Hide"
        value = "backend-Request-Test"
      }
      headers {
        mode  = "Mask"
        value = "backend-Request-Header"
      }
    }
  }

  backend_response {
    body_bytes     = 10
    headers_to_log = ["Content-Type"]
    data_masking {
      query_params {
        mode  = "Hide"
        value = "backend-Request-Test"
      }
      headers {
        mode  = "Mask"
        value = "backend-Request-Header"
      }
    }
  }
  operation_name_format = "Name"
}
