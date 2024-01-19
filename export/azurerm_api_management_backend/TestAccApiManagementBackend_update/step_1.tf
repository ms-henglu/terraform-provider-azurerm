

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024407439707-update"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240119024407439707-update"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}


resource "azurerm_api_management_backend" "test" {
  name                = "acctestapi-240119024407439707"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  protocol            = "soap"
  url                 = "https://updatedacctest"
  description         = "description"
  resource_id         = "https://resourceid"
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
