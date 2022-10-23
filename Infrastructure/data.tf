# # # ----- Run Userdata ----- ##
# data "cloudinit_config" "shell" {
#   gzip          = false
#   base64_encode = false

#   part {
#     content_type = "text/x-shellscript"
#     filename     = "keyrevive"
#     content = templatefile("./scripts/keyrevive.sh",

#       {
#         vmip = azurerm_linux_virtual_machine.Linuxvm.public_ip_address
#         path = var.path_privatekey
#     })
#   }
# }