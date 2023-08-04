
			
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025436274687"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230804025436274687"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-230804025436274687"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230804025436274687"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-230804025436274687"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd176!"
  provision_vm_agent              = false
  allow_extension_operations      = false
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-230804025436274687"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEA8ZD7IjOucvQoBUg1yo2EfgSyGFzR+1qzViSLa5qLKNhN6zhigAgY3KdwIYGaT/bEjjmyvokeSxD0fDDnxeM41Ztn51hQci2HSKcJxbbWsIzvHPSlslHp6uQLfLgCALLMQhkbTLCho6BYJKhDP4lqPCHEmSdYfWM1UtyxULSlbR7yMmFzI5cDmu1tPaVYQ7sldwdEF1GPZWUQXES4mM6vKac2uhYg2myB8wqJ0fRqqija8OWVz1+ju/UGaPegRS8bpmja6QrhSjxMCfmV4UYwQrBOtJxEYyu1iMdeLQWtIl895AnBVTnBdM8+SD/l/0p62oYBUQl0qv2W5oVOdIPEm61mVl0paxxUQJvDTCdZYpDIb2fUl+JQ+IUXQYLtbkaFub08GH1J7xxTkCjK/bQhCXBrAwe6KsyvbuSfNk5mYZdZoT+YpB6Tj3oBUOVs6Q4Fc+iWictEljyQkJy3lp1hITj3QCe00zCQodTPKudfP1WDSYAP6Kwp/m3q7r/Tdn5pyMETRyibRxdgIhCa8ccXsP0ZYX4NgUITmLEpMkxgx7hJuDrr2tllqh7jb/tj9tbGq8SUP0LyRgFJAmzipAVk9Gtn2nVqwbQ5FW9QC6/buHipikcxGYpqCYqZKFHhzd2/ET6pt49nmQ11Vg1aXrRTh8jfUe4VR+ASXAh8OdruF/8CAwEAAQ=="

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENV = "Test"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd176!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-230804025436274687"
    location            = azurerm_resource_group.test.location
    tenant_id           = "ARM_TENANT_ID"
    working_dir         = "/home/adminuser"
  })
  destination = "/home/adminuser/install_agent.sh"
}

provisioner "file" {
  source      = "testdata/install_agent.py"
  destination = "/home/adminuser/install_agent.py"
}

provisioner "file" {
  source      = "testdata/kind.yaml"
  destination = "/home/adminuser/kind.yaml"
}

provisioner "file" {
  content     = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIJKgIBAAKCAgEA8ZD7IjOucvQoBUg1yo2EfgSyGFzR+1qzViSLa5qLKNhN6zhi
gAgY3KdwIYGaT/bEjjmyvokeSxD0fDDnxeM41Ztn51hQci2HSKcJxbbWsIzvHPSl
slHp6uQLfLgCALLMQhkbTLCho6BYJKhDP4lqPCHEmSdYfWM1UtyxULSlbR7yMmFz
I5cDmu1tPaVYQ7sldwdEF1GPZWUQXES4mM6vKac2uhYg2myB8wqJ0fRqqija8OWV
z1+ju/UGaPegRS8bpmja6QrhSjxMCfmV4UYwQrBOtJxEYyu1iMdeLQWtIl895AnB
VTnBdM8+SD/l/0p62oYBUQl0qv2W5oVOdIPEm61mVl0paxxUQJvDTCdZYpDIb2fU
l+JQ+IUXQYLtbkaFub08GH1J7xxTkCjK/bQhCXBrAwe6KsyvbuSfNk5mYZdZoT+Y
pB6Tj3oBUOVs6Q4Fc+iWictEljyQkJy3lp1hITj3QCe00zCQodTPKudfP1WDSYAP
6Kwp/m3q7r/Tdn5pyMETRyibRxdgIhCa8ccXsP0ZYX4NgUITmLEpMkxgx7hJuDrr
2tllqh7jb/tj9tbGq8SUP0LyRgFJAmzipAVk9Gtn2nVqwbQ5FW9QC6/buHipikcx
GYpqCYqZKFHhzd2/ET6pt49nmQ11Vg1aXrRTh8jfUe4VR+ASXAh8OdruF/8CAwEA
AQKCAgBn84W+YBMP8LVQIJTVRzTerdKd3UOXMJ6/0RYWBfkgaISPVkI86j8YpQ0B
vi3Tf1NyCK48g/D/SJqM3ta+N1t7wFZkHYLwv1raDteLt3SHoP48raKoK8vHgr7W
urBR8J8pSniO9et46EVF8QqPSujmW3moll/kBU8rC0Fag4I0hP6gY4MSq6engchi
oMZszxn+MKhCiJx2e5kgu4ncaATEnepVBbS5ibwaBEzuholoFBCzXXisNnHVLknF
3dmgK/dwEusxIbd1JKFsIXU37eZSrGASJLThICwMYg7KvQiWI/oUKYaC0EnJpG0e
1jB5PWnEo6npX3JPKrVHGdJ7HUD7DvVhT2W9fuEabDgpd5y+25ykoCCXjtmsuIiF
41zy1C2gE8jCf6OpWcXFIvUNVr7WHv8k1Vs1d8tXmefepXsxoPjmYn3KVUtc0dla
IVeICXkx2W0dKeUrU78VYuGmJdcj70kB8QIIM4UsASaayRmamF+l47lmUSMWCYtb
UyFP2wD9GVXUk8EOCSvrygDIj4NCWHMo5HGB/K6y49OsNAQNQEtD/akNEVFPalpz
bWCYbapfL+kC6s4HNZWLrJ1h/ysz6w/NyQjDPWSbmASISlJ24pocrOHzPRw6g6u/
P7TEB3DWznXl+UF3fAtnRmhCiuzpddmZHuts2+wdd4N0Q6zv0QKCAQEA/64YzONv
SgC25QRjxhjp2mHHZf1wzL1poQX9RttjIQBg8IzHPQef1ASt+W+83M4Glcq/32j2
NbjZdyDmI9CMeMH6x4cympRPDXbWu/L8OrYS+hLMRuFKRJarsw7VzZuYZxDibmpk
njOD5XV41FdNBY4G5FS9/Udh7XFRUCGR5npBZzCv8LfRUPo6Bm0/EMAWYmiqj4/E
8ny+JBd5x6wg5V8iJIUXb0l8fMqstWuRhs3ytpqQzXmpRSEiOHf0lCoqTlvYlMLN
8dGJeo9UKui+2FvI9MuN+vg0uBxuYIJMlQyxDW9SACenmQcE5rUeAgnOtCEE+vPi
fXM4ehW1MokwRQKCAQEA8d5c7Yr7U2at66lXvj0N3l02sksgxYC3qh/XSgF3ber5
jAc4Vs5GFUh8HMhOXkRQ68Criu7xyg+7xwBHJjrGwfGmLx7sxsXhsx//9MawYRG7
Nad/8fwqrsXC+1nFTOswfkVEmPUX+kmDneJwDFi4QPEeV0IFD8hQB0LoKCQrB/FX
359mmotyodW2dbjUtqJidEwpVAborepCro9CsmrAF5dO0l2729iZgv+2E43rgoZ3
o/fN1PmCwlJPZq14l4HRsyJ5p6nR06ciQOSD5cw9dfUz8R4tgld+AdUYY4eqa7Wa
5JcugQDd7Lv9OSrmOHmAtCHjgJZVLdGdV3Sy9dTVcwKCAQEAzgkxmwo8CFqDCBJ9
hIlXCdB5qsqNN6/7ivMUoyDvxQxVEgOgGqImPeh3eeZ9P0IXNGZqMFKY9bm8JK+y
RXItgLJwsJFWShLxkVwOtu6cK4PFzxeO3h92hccVHfn6ePHF4mhMz8WUx5ej1ijP
8e1X9/33t9BCOfRoCbujVvt2Y1BpnAoz/btjReofEEbA53KjlzHZIE8u2mmDn/n6
/NjMuYnsLZnCxL9nPfjlLF0+rG8SA+ySe8JqkXad6PthcHR6GyMQaPCCnTfJnaYa
oWllQVzVl87g3zlc4nCm0cauh/3uP3FRlyZdfIeXf4K8Z9AXbjidls0p2wYaoOcV
WWAMMQKCAQEAtSEYKJBXTIrtnjkwS3g/hZH63ySiAyY05QN5X6Ofg8JfZX0WtPM+
yruArrFW9wNkMlkUXjQ5AGAt+IZ9weRsaluEX29iVC1mq5VAQlf1SIxVzYWFrHty
n3XcYg1FUygiJb3L9Fw/u6EIHtmvnZ9nRMMNPL1lOv+A5x806rLDQux7KS2fUgcy
Ln30aU6kha0v2/YZUSLnZy6zBzSj9yc4ebJHRgUKJUadF9xVx2kVwKbgu/tcuqys
PsgTTEqGr7d5ihQ8VNI5H67fWQeIuzPrpwWdA2ndHOpWpBqobAjyGD1lJOEO4275
w0q5BPHafNqJBt0GGYr7eResJA1x4+WifwKCAQEAxVRKZCwuQHJz53MOrInS2Asm
eHmQ2K3EdGoSg0MdkDfOpx/3uwYcTRFMJYjjMmuiEpfxM997csjVA62URgmtjab6
OWPYrnRQWJ/K7WXImFgsCty8FERXx5GzLDsKP/0kb3d8NUMhQ/6YYRylJEw9pUuH
L2RjsD6ISyXaReEmS9P2TvLyhVoEXn6HSfApI9Quj9JSksuX2/AjGb8905zdxEMc
daijjHb5YCBPm1XAjXDsHvdvfRWKJSmGDUiQ5TscrkmdqIlnOug04uDrn4uJFS4p
2OhDbEa6LJUDgt/SbE5Ae2i3EEr0poPWAGzZWlp841cl4sDGCP9Zi0C1940cBA==
-----END RSA PRIVATE KEY-----

EOT
  destination = "/home/adminuser/private.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/\r$//' /home/adminuser/install_agent.sh",
    "sudo chmod +x /home/adminuser/install_agent.sh",
    "bash /home/adminuser/install_agent.sh > /home/adminuser/agent_log",
  ]
}


  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}
