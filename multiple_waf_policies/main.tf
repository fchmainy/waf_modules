resource "bigip_ltm_policy" "multiple" {
    controls = ["asm", "forwarding"]
    name     = "/${var.partition}/${var.name}"
    requires = ["http"]
    strategy = "best-match"

    dynamic "rule" {
	for_each				= var.rules
	content {
		name				= rule.value.name
		condition {
			case_insensitive	= true
			contains		= rule.value.hostname == null ? false : true
			starts_with		= rule.value.path == null ? false : true
			external		= true
			present			= true
			remote			= true
			request			= true
			host			= rule.value.hostname == null ? false : true
			http_host               = rule.value.hostname == null ? false : true
			path 			= rule.value.path == null ? false : true
			values			= rule.value.hostname == null ? rule.value.hostname : rule.value.path
		}
		action {
			forward			= true
			pool			= "/${var.partition}/${rule.value.pool_name}"
			request			= true
			select			= true
			snat			= "automap"
		}
		action {
			asm			= true
			enable			= true
			request			= true
			policy			= "/${var.partition}/${rule.value.policy}"
		}
	}
    }
	rule {
		name				= "default"
		action	{
			asm			= true
			enable			= true
			policy			= "/${var.partition}/${var.default_policy}"
			request			= true
		}
	}
}
