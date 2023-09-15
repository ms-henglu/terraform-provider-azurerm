


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230915022932629531"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-230915022932629531"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_certificate" "test" {
  name                    = "acctest-230915022932629531"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  base64                  = filebase64("testdata/automation_certificate_test.pfx")
}


resource "azurerm_automation_connection_certificate" "test" {
  name                        = "acctestACC-230915022932629531"
  resource_group_name         = azurerm_resource_group.test.name
  automation_account_name     = azurerm_automation_account.test.name
  automation_certificate_name = azurerm_automation_certificate.test.name
  subscription_id             = data.azurerm_client_config.test.subscription_id
}


resource "azurerm_automation_connection_certificate" "import" {
  name                        = azurerm_automation_connection_certificate.test.name
  resource_group_name         = azurerm_automation_connection_certificate.test.resource_group_name
  automation_account_name     = azurerm_automation_connection_certificate.test.automation_account_name
  automation_certificate_name = azurerm_automation_connection_certificate.test.automation_certificate_name
  subscription_id             = azurerm_automation_connection_certificate.test.subscription_id
}
