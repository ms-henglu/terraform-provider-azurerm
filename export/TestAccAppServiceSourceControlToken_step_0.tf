
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "13chks7hgc0fqrrohloxqr8lr7yghxialf1wacl4p"
  token_secret = "jmx6m13zzncmkyktaviy3kfymj0lzf37e1yho3wht"
}
