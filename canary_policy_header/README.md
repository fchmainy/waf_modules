# Canary Testing of WAF Policies



## Why it matters?
No matter how intelligent your security gears are, enforcing is always a sensitive operation. Therefore, instead of changing arguments on a policy, you may want to create a new instance of the policy, make the change on it and progressively migrate the users to the new instance.
</br>
</br>
</br>
## Explain the Nuts & Bolts
Behind the scene, the module implements the **"bigip_ltm_policy"** terraform resource with some conditions on a header (which could also have been a cookie). 
</br>
</br>
</br>

## Example in Terraform


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
  source = "github.com/fchmainy/waf_modules//canary_policy_header?ref=v1.0.6"
  providers = {
    bigip = bigip.prod
  }
  name               = "canary2"
  partition          = "Common"
  header_name        = "user_profile"
  header_value	     = "earlyAdopter"
  new_waf_policy     = bigip_waf_policy.app1_waf_v2.name
  current_waf_policy = bigip_waf_policy.app1_waf_v1.name
  depends_on         = [bigip_waf_policy.app1_waf_v1, bigip_waf_policy.app1_waf_v2]
}
```
