
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "ha1o9t2yvpq0a3a1fjwv0ixnzpxjx6msy77vch48o"
  token_secret = "drz3hojqwrqvxybytnj4pqdktzzgvj62rqwv163u3"
}
