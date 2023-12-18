


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-231218071216220894"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-231218071216220894"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEAvUro29E+xq240W2ZcrLVXWCNH7X57kM5nH+3f2TuSpw4SY3LHFVeVQDO2ktVNgbSYMMBI1vZQqUkNJVmjAs8RqEyts3It+XyY0jWAPd9vllA//mASUN6lP9U/C2A3hT3ECKfSZebpBvvCxh2aJVoWNjlg2VlFg5yAgE3EbL3I86nmc/0Rs0CU6EGKqxYToyn9xkZbHimHVR51kTJQd8cmsND+WXa0N1S6D1EySMNWKoRsHD2BtRl8+8wF3fdkrGN+8477rFhyPfxrEGskRM/k47uGg4JFLvvnMXSPyHk9PaOJxfagqUm0NTdA+ARVZy9gVhKfrV72eGZOfJufa0bIdtuhL1Ylu9XpCEk6AwKS2B38NhltJ7CU21rs3u8ise9wMIM24I4DdFX5A3o//P4RcayDUMbdsSZjc9570cSDIU1u9qXonlLXu+ojQa4p5pliDz2OGWyRM42tBB/qfD0wHqjd7bRB5nzS/9hrX8wJLWEGfXRT1PQ+K0dmusXUoySkpl/Z3xq6Cu9a2hxObVKWkeunwj19Sku2a+64B/wPmqWHvOkx6bwbb6Rp48z7t4GGU3iki4n6SJan2gswwhirTSiBVw2zEie7qyPBEqYpimiwxd5lVXog3OzxBLFLJFZtt/TtTwJxUej6/0UDN4Qv3CF+CAar8C8NA6mlokU8bcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
