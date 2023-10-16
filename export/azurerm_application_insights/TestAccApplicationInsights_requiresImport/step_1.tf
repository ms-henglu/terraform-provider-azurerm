

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-231016033318117394"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-231016033318117394"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}


resource "azurerm_application_insights" "import" {
  name                = azurerm_application_insights.test.name
  location            = azurerm_application_insights.test.location
  resource_group_name = azurerm_application_insights.test.resource_group_name
  application_type    = azurerm_application_insights.test.application_type
}
