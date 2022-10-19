variable name {
        type    = string
        default = ""

}

variable partition {
        type    = string
        default = "Common"
}

variable rules {
        type = list(object({
                name            = string
                hostname        = optional(list(string))
                path            = optional(list(string))
                policy          = string
        }))
}

variable pool_name {
	type			= string
	default			= ""
}
	
variable default_policy {
	type			= string
	default			= ""
}
