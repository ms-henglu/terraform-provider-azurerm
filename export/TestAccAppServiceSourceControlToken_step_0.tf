
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "comkkptzp63mm4mehuqgkg41spliadapgi1vwnurm"
  token_secret = "16tjejk8yfeh6tzjkxjs7jzz4vfbnofm6izu0y33m"
}
