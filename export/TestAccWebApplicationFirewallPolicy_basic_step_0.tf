
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014936478000"
  location = "West Europe"
}

resource "azurerm_web_application_firewall_policy" "test" {
  name                = "acctestwafpolicy-211015014936478000"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location


  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.1"
    }
  }

  policy_settings {
    enabled = true
    mode    = "Detection"
  }
}
