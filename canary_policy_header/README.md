# Canary Testing of WAF Policies

## Goal


# Example



```terraform
resource "bigip_waf_policy" "app1_waf_v1" {
  provider             = bigip.prod
  description          = "Current version of the WAF Policy"
  name                 = "v1"
  partition            = "Common"
  template_name        = "POLICY_TEMPLATE_RAPID_DEPLOYMENT"
  application_language = "utf-8"
  enforcement_mode     = "blocking"
  server_technologies  = ["Apache Tomcat", "MySQL", "Unix/Linux"]
}

resource "bigip_waf_policy" "app1_waf_v2" {
  provider             = bigip.prod
  description          = "new version of the WAF Policy"
  name                 = "v2"
  partition            = "Common"
  template_name        = "POLICY_TEMPLATE_RAPID_DEPLOYMENT"
  application_language = "utf-8"
  enforcement_mode     = "blocking"
  server_technologies  = ["Apache Tomcat", "MySQL", "Unix/Linux", "MongoDB"]
}
```


```terraform
module "canary_app1" {
  source = "../modules/canary_policy_header"
  providers = {
    bigip = bigip.prod
  }
  name               = "canary2"
  partition          = "Common"
  header_name        = "user_profile"
  header_value	     = "earlyAdopter"
  new_waf_policy     = bigip_waf_policy.app1_waf_v2.name
  current_waf_policy = bigip_waf_policy.app1_waf_v1.name
}
```
