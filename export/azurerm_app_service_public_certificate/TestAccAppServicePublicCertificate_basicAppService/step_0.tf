
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestpubcert230915024406987787"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestpubcert-230915024406987787"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "acctestpubcert-230915024406987787"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
}

resource "azurerm_app_service_public_certificate" "test" {
  resource_group_name  = azurerm_resource_group.test.name
  app_service_name     = azurerm_app_service.test.name
  certificate_name     = "acctestpubcert-230915024406987787"
  certificate_location = "Unknown"
  blob                 = filebase64("testdata/app_service_public_certificate.cer")
}
