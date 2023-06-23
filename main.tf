resource "azurerm_resource_group" "rg" {
  count    = 2
  name     = "rg-leander"
  location = var.location
  tags = {
    Environment  = "Test"
    Team         = "DevOps"
    Kostenplaats = "987654321"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-leander"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-leander"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip" {
  name                = "public-leander"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "sg-leander"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

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

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "nic-leander"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-leander"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# resource "azurerm_network_interface" "nic2" {
#   name                      = "nic-leander2"
#   location                  = var.location
#   resource_group_name       = azurerm_resource_group.rg.name

#   ip_configuration {
#     name                          = "nic-leander2"
#     subnet_id                     = azurerm_subnet.subnet.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# Create a Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-leander"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_F2"
  admin_username      = "sysop"

  network_interface_ids = [
    azurerm_network_interface.nic.id,
    #azurerm_network_interface.nic2.id
  ]

  admin_ssh_key {
    username   = "sysop"
    #public_key = file("~/.ssh/id_rsa.pub")
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDDYp7qdg8MMOr6pRPshLuXJsJPSXzJDOEvX620gcmo6yXt3wrIe0EjDY+syLcnZrMGu1ZNkiha9iEdMk+/4rObaXC++Yp0pkUK3MrS4To9duawv26ogXZvfWRQavJCio+loWNSYXS21vmpE0gwV4GFV9xA48z1bWvGjJjMj5RKJ0fpwGB//vxg9ij1qtgakhjqVjjR8T+n4YplqET+6FYJwR7KhYGGdprhwZyH1K3QPsmK/ZsfTs5tkwP4Y70I3vk2zX+wfcowy56PzxVhkSdVr0VN4CsH5tVv2cB7DHRJ70JQfKTeDI1CJOMe56Jz97XXMtirJmRmoHdyvbQ5jk9p"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicip.name
  resource_group_name = azurerm_linux_virtual_machine.vm.resource_group_name
  #  depends_on          = [azurerm_linux_virtual_machine.vm]
}
