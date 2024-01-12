

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033744157661"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240112033744157661"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-240112033744157661"
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

resource "azurerm_api_management_api_schema" "test" {
  api_name            = azurerm_api_management_api.test.name
  api_management_name = azurerm_api_management_api.test.api_management_name
  resource_group_name = azurerm_api_management_api.test.resource_group_name
  schema_id           = "acctestSchema240112033744157661"
  content_type        = "application/json"
  value               = file("testdata/api_management_api_schema_swagger.json")
}

resource "azurerm_api_management_api_operation" "test" {
  operation_id        = "acctest-operation"
  api_name            = azurerm_api_management_api.test.name
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  display_name        = "Acceptance Test Operation"
  method              = "DELETE"
  url_template        = "/user1"
  description         = "This can only be done by the logged in user."

  request {
    description = "Created user object"

    header {
      name     = "X-Test-Operation"
      required = true
      type     = "string"
      values   = ["application/x-www-form-urlencoded"]
    }

    representation {
      content_type = "application/json"
      type_name    = "User"
    }
  }

  response {
    status_code = 200
    description = "successful operation"

    header {
      name     = "X-Test-Operation"
      required = true
      type     = "string"

      type_name = "User"
      schema_id = azurerm_api_management_api_schema.test.schema_id
      example {
        description    = "This is a test description"
        external_value = "https://example.com/foo/bar"
        name           = "test"
        summary        = "This is a test summary"
        value          = "backend-Request-Test"
      }
    }

    representation {
      content_type = "application/xml"

      example {
        name  = "sample"
        value = <<SAMPLE
<response>
  <user name="bravo24">
    <groups>
      <group id="abc123" name="First Group" />
      <group id="bcd234" name="Second Group" />
    </groups>
  </user> 
</response>
SAMPLE

      }
    }
  }
}
