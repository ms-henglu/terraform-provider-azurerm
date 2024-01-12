
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "whesf8oupyjgdwi43lo41lr4l3t8iqfrhkwrpyluv"
  token_secret = "z2hlua9ryqj9a71kapfo7j8xir03kq4ceqequ3r08"
}
