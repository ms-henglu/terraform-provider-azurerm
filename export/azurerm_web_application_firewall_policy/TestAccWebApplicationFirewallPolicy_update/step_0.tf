
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034431074886"
  location = "West Europe"
}

resource "azurerm_web_application_firewall_policy" "test" {
  name                = "acctestwafpolicy-231016034431074886"
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
