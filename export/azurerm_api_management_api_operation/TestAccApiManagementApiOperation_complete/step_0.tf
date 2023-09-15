

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022812138802"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230915022812138802"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-230915022812138802"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "Butter Parser"
  path                = "butter-parser"
  protocols           = ["https", "http"]
  revision            = "3"
  description         = "What is my purpose? You parse butter."
  service_url         = "https://example.com/foo/bar"

  subscription_key_parameter_names {
    header = "X-Butter-Robot-API-Key"
    query  = "location"
  }
}


resource "azurerm_api_management_api_operation" "test" {
  operation_id        = "acctest-operation"
  api_name            = azurerm_api_management_api.test.name
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  display_name        = "DELETE Resource"
  method              = "DELETE"
  url_template        = "/resource"

  response {
    status_code = 200

    header {
      name          = "test"
      required      = true
      type          = "string"
      default_value = "default"
      description   = "This is a test description"
      values        = ["multipart/form-data"]
    }

    representation {
      content_type = "multipart/form-data"

      form_parameter {
        default_value = "multipart/form-data"
        description   = "This is a test description"
        name          = "test"
        required      = true
        type          = "string"
        values        = ["multipart/form-data"]
      }

      example {
        name           = "test"
        description    = "This is a test description"
        external_value = "https://example.com/foo/bar"
        summary        = "This is a test summary"
      }
    }
  }

  request {
    description = "Created user object"

    query_parameter {
      default_value = "multipart/form-data"
      description   = "This is a test description"
      name          = "test"
      required      = true
      type          = "string"
      values        = ["multipart/form-data"]
    }

    header {
      name          = "test"
      required      = true
      type          = "string"
      default_value = "default"
      description   = "This is a test description"
    }

    representation {
      content_type = "multipart/form-data"

      example {
        description    = "This is a test description"
        external_value = "https://example.com/foo/bar"
        name           = "test"
        summary        = "This is a test summary"
        value          = "backend-Request-Test"
      }

      form_parameter {
        default_value = "multipart/form-data"
        description   = "This is a test description"
        name          = "test"
        required      = true
        type          = "string"
        values        = ["multipart/form-data"]
      }
    }
  }
}
