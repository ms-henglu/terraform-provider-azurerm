

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-cdn-afdx-230512010322360465"
  location = "West Europe"
}

resource "azurerm_cdn_frontdoor_profile" "test" {
  name                = "acctest-fdprofile-230512010322360465"
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Standard_AzureFrontDoor"
}


resource "azurerm_cdn_frontdoor_rule_set" "test" {
  name                     = "acctestfdruleset23051265"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}


resource "azurerm_cdn_frontdoor_rule_set" "import" {
  name                     = azurerm_cdn_frontdoor_rule_set.test.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.test.id
}
