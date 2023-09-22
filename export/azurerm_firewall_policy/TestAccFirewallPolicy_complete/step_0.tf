

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-networkfw-230922061138890409"
  location = "West Europe"
}

resource "azurerm_firewall_policy" "test" {
  name                     = "acctest-networkfw-Policy-230922061138890409"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  threat_intelligence_mode = "Off"
  threat_intelligence_allowlist {
    ip_addresses = ["1.1.1.1", "2.2.2.2", "10.0.0.0/16"]
    fqdns        = ["foo.com", "bar.com"]
  }
  explicit_proxy {
    enabled         = true
    http_port       = 8087
    https_port      = 8088
    enable_pac_file = true
    pac_file_port   = 8089
    pac_file        = "https://tinawstorage.file.core.windows.net/?sv=2020-02-10&ss=bfqt&srt=sco&sp=rwdlacuptfx&se=2021-06-04T07:01:12Z&st=2021-06-03T23:01:12Z&sip=68.65.171.11&spr=https&sig=Plsa0RRVpGbY0IETZZOT6znOHcSro71LLTTbzquYPgs%3D"
  }
  auto_learn_private_ranges_enabled = true
  dns {
    servers       = ["1.1.1.1", "3.3.3.3", "2.2.2.2"]
    proxy_enabled = true
  }
  tags = {
    env = "Test"
  }
}
