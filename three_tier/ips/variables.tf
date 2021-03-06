# templates directory
variable templates {
  default = "/workspace/templates"
}
variable location {}
variable region {}
variable prefix {}
variable resourceGroup {
  default = "scca-tf-rg"
}
variable securityGroup {
  default = "none"
}

#variable subnetInspectExt { }
#variable subnetInspectInt { }
variable subnets {}
variable virtual_network_name {}

variable ips01ext {}
variable ips01int {}
variable adminUserName { default = "admin" }
variable adminPassword { default = "2017F5Networks!!" }

# TAGS
variable purpose { default = "public" }
variable environment { default = "f5env" } #ex. dev/staging/prod
variable owner { default = "f5owner" }
variable group { default = "f5group" }
variable costcenter { default = "f5costcenter" }
variable application { default = "f5app" }
