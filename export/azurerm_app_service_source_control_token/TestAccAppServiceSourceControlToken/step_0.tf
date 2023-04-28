
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "guz0va8vyx9buerywzekvkauu07kvrg7ndx6zg72y"
  token_secret = "x1pp3qyr214lam4vq28j12e72de6l79cufkxu8f29"
}
