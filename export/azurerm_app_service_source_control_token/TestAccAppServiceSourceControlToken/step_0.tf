
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "uv3z27tp8ez9x2p6ckepwwimbsulk7g3f7pw9o3yj"
  token_secret = "6fokn0mtvhd7u2dbior1zsntuekmvx8dqfkk1ams7"
}
