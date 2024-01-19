


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024407421319"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240119024407421319"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-240119024407421319"
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

  contact {
    email = "test@test.com"
    name  = "test"
    url   = "https://example:8080"
  }

  license {
    name = "test-license"
    url  = "https://example:8080/license"
  }

  terms_of_service_url = "https://example:8080/service"
}


resource "azurerm_api_management_api" "revision" {
  name                 = "acctestRevision-240119024407421319"
  resource_group_name  = azurerm_resource_group.test.name
  api_management_name  = azurerm_api_management.test.name
  revision             = "18"
  source_api_id        = "${azurerm_api_management_api.test.id};rev=3"
  revision_description = "Creating a Revision of an existing API"
  contact {
    email = "test@test.com"
    name  = "test"
    url   = "https://example:8080"
  }

  license {
    name = "test-license"
    url  = "https://example:8080/license"
  }

  terms_of_service_url = "https://example:8080/service"
}
