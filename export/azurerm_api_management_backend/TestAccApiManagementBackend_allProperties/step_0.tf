

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230728031655481557-all"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230728031655481557-all"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_certificate" "test" {
  name                = "example-cert"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  data                = filebase64("testdata/keyvaultcert.pfx")
  password            = ""
}

resource "azurerm_api_management_backend" "test" {
  name                = "acctestapi-230728031655481557"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  protocol            = "http"
  url                 = "https://acctest"
  description         = "description"
  resource_id         = "https://resourceid"
  title               = "title"
  credentials {
    authorization {
      parameter = "parameter"
      scheme    = "scheme"
    }
    certificate = [
      azurerm_api_management_certificate.test.thumbprint,
    ]
    header = {
      header1 = "header1value1,header1value2"
      header2 = "header2value1,header2value2"
    }
    query = {
      query1 = "query1value1,query1value2"
      query2 = "query2value1,query2value2"
    }
  }
  proxy {
    url      = "http://192.168.1.1:8080"
    username = "username"
    password = "password"
  }
  tls {
    validate_certificate_chain = false
    validate_certificate_name  = true
  }
}
