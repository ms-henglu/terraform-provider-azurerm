
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "kf3o8o8zftk0263v8sppp3dr760oa6cehs0g843sl"
  token_secret = "7shttthx3rzct32nd7vlryi3o80r6wmk161zmzefh"
}
