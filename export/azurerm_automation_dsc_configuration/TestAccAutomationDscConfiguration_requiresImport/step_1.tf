

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240119024539556774"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240119024539556774"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_dsc_configuration" "test" {
  name                    = "acctest"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  location                = azurerm_resource_group.test.location
  content_embedded        = "configuration acctest {}"
  description             = "test"

  tags = {
    ENV = "prod"
  }
}


resource "azurerm_automation_dsc_configuration" "import" {
  name                    = azurerm_automation_dsc_configuration.test.name
  resource_group_name     = azurerm_automation_dsc_configuration.test.resource_group_name
  automation_account_name = azurerm_automation_dsc_configuration.test.automation_account_name
  location                = azurerm_automation_dsc_configuration.test.location
  content_embedded        = azurerm_automation_dsc_configuration.test.content_embedded
  description             = azurerm_automation_dsc_configuration.test.description
}
