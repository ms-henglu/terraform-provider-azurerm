
provider "azurerm" {
  features {
    application_insights {
      disable_generated_rule = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-231016033318112942"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-231016033318112942"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}
