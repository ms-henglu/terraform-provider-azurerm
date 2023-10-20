
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "dvgycjbdnr8979i2um7q4lwmt6hu11hutsjq8jooa"
  token_secret = "e3fs9jnkqepf6kt9a3p7qho29qb1girnmastwbfj7"
}
