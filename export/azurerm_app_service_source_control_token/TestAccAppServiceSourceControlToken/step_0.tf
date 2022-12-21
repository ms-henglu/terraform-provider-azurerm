
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "o3k67hpromhewbu0oe19nw2qpuam664r7fca3aiwp"
  token_secret = "tccb4wi37f8c1b66iijt993brwimmrpovljx069t9"
}
