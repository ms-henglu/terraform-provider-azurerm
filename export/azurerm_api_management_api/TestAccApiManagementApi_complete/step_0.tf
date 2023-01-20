

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230120054208990452"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230120054208990452"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-230120054208990452"
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
