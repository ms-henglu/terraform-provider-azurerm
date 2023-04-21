
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "bstqu0t4ct68f84rciugwzj9mfg0t64lt3wt08zr0"
  token_secret = "jrs1f7wk1lxezuh2kkzrsrzeplscyy92ivwtij1ex"
}
