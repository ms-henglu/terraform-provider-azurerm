
provider "azurerm" {
  features {
    application_insights {
      disable_generated_rule = true
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-230804025354462005"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                = "acctestappinsights-230804025354462005"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  application_type    = "web"
}
