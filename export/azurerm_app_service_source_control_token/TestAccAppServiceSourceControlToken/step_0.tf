
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "6anlxae67d1dumbj87ijluhth96jvkskracg3mo3f"
  token_secret = "kwmxcz7wrkofuikbs91ma6f0kcq34vj6sl3cya699"
}
