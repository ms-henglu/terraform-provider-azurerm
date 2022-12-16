

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221216013034370114"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221216013034370114"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}


resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-221216013034370114"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"

  import {
    content_value  = file("testdata/api_management_api_wsdl.xml")
    content_format = "wsdl"

    wsdl_selector {
      service_name  = "Calculator"
      endpoint_name = "CalculatorHttpsSoap11Endpoint"
    }
  }
}
