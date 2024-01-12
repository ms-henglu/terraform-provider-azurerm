
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224958340661"
  location = "West Europe"
}

resource "azurerm_web_application_firewall_policy" "test" {
  name                = "acctestwafpolicy-240112224958340661"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    env = "test"
  }

  policy_settings {
    enabled                     = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
    mode                        = "Prevention"
    request_body_check          = false
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.1"

      rule_group_override {
        disabled_rules = [
          "800112",
          "800111",
          "800110",
          "800100",
          "800113",
        ]
        rule_group_name = "Known-CVEs"
      }
    }
  }
}
