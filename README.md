# Learning Chef

## 1. Getting started 

```
vagrant box add bento/centos-7.2 --provider=virtualbox
vagrant init bento/centos-7.2

vagrant ssh
[vagrant@localhost ~]$ curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -c stable
[vagrant@localhost ~]$ curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk -c stable
```

default mode for chef-client attempts to contact a chef server for the receipes to run.

`--local-mode` (or -z) overrides taht behaviro.

```
[vagrant@localhost ~]$ sudo chef-client --local-mode hello.rb
[2020-03-10T00:41:36+00:00] WARN: No config file found or specified on command line. Using command line options instead.
[2020-03-10T00:41:36+00:00] WARN: No cookbooks directory found at or above current directory.  Assuming /home/vagrant.
+---------------------------------------------+
            Chef License Acceptance

Before you can continue, 2 product licenses
must be accepted. View the license at
https://www.chef.io/end-user-license-agreement/

Licenses that need accepting:
  * Chef Infra Client
  * Chef InSpec

Do you accept the 2 product licenses (yes/no)?

> yes

Persisting 2 product licenses...
✔ 2 product licenses persisted.

+---------------------------------------------+
Starting Chef Infra Client, version 15.7.32
resolving cookbooks for run list: []
Synchronizing Cookbooks:
Installing Cookbook Gems:
Compiling Cookbooks...
[2020-03-10T00:41:57+00:00] WARN: Node localhost has an empty run list.
Converging 1 resources
Recipe: @recipe_files::/home/vagrant/hello.rb
  * file[/hello.text] action create
    - create new file /hello.text
    - update content in file /hello.text from none to 315f5b
    --- /hello.text	2020-03-10 00:41:57.633490361 +0000
    +++ /.chef-hello20200310-11278-j4fruh.text	2020-03-10 00:41:57.633490361 +0000
    @@ -1 +1,2 @@
    +Hello, world!
    - restore selinux security context

Running handlers:
Running handlers complete
Chef Infra Client finished, 1/1 resources updated in 01 seconds
```

## 2. From Recipes to Cookbooks

### Test and repair

chef-client takes action only when it needs to. chef looks at the current state of each resource and takes action only when that resource is out of policy.

### Cookbook

the fundamental unit of configuration and policy distribution

```
[vagrant@localhost ~]$ chef generate cookbook cookbooks/apache
Generating cookbook apache
- Ensuring correct cookbook content

Your cookbook is ready. Type `cd cookbooks/apache` to enter it.

There are several commands you can run to get started locally developing and testing your cookbook.
Type `delivery local --help` to see a full list of local testing commands.

Why not start by writing an InSpec test? Tests for the default recipe are stored at:

test/integration/default/default_test.rb

If you'd prefer to dive right in, the default recipe can be found at:

recipes/default.rb
```

```
[vagrant@localhost apache]$ tree
.
├── CHANGELOG.md
├── chefignore
├── kitchen.yml
├── LICENSE
├── metadata.rb
├── Policyfile.rb
├── README.md
├── recipes
│   └── default.rb
├── spec
│   ├── spec_helper.rb
│   └── unit
│       └── recipes
│           └── default_spec.rb
└── test
    └── integration
        └── default
            └── default_test.rb

```

```
[vagrant@localhost apache]$ chef generate recipe . server
[vagrant@localhost apache]$ tree
.
├── CHANGELOG.md
├── chefignore
├── kitchen.yml
├── LICENSE
├── metadata.rb
├── Policyfile.rb
├── README.md
├── recipes
│   ├── default.rb
│   └── server.rb
├── spec
│   ├── spec_helper.rb
│   └── unit
│       └── recipes
│           ├── default_spec.rb
│           └── server_spec.rb
└── test
    └── integration
        └── default
            ├── default_test.rb
            └── server_test.rb

7 directories, 14 files
```

```
[vagrant@localhost apache]$ sudo chef-client --local-mode recipes/server.rb
[vagrant@localhost apache]$ curl localhost
<h1>Hello, world!</h1>
```

a run list is an ordered collection of receipts to execute.

```
[vagrant@localhost apache]$ sudo chef-client --local-mode --runlist "recipe[apache::server]"
[2020-03-10T02:39:32+00:00] WARN: No config file found or specified on command line. Using command line options instead.
Starting Chef Infra Client, version 15.7.32
resolving cookbooks for run list: ["apache::server"]
Synchronizing Cookbooks:
  - apache (0.1.0)
Installing Cookbook Gems:
Compiling Cookbooks...
Converging 3 resources
Recipe: apache::server
  * yum_package[httpd] action install (up to date)
  * file[/var/www/html/index.html] action create (up to date)
  * service[httpd] action start (up to date)
  * service[httpd] action enable (up to date)

Running handlers:
Running handlers complete
Chef Infra Client finished, 0/4 resources updated in 01 seconds
```

shorthand:

```
[vagrant@localhost apache]$ sudo chef-client -zr "recipe[apache::server]"
```

apply the default recipe:

```
-r "recipe[COOKBOOK(::default)]"
```

```
[vagrant@localhost apache]$ sudo chef-client -zr "recipe[apache::default]"
[vagrant@localhost apache]$ sudo chef-client -zr "recipe[apache]"
```

### Including a recipe: include_recipe

```
[vagrant@localhost ~]$ vim cookbooks/apache/recipes/default.rb
include_recipe 'apache::server'
```

```
[vagrant@localhost ~]$ sudo chef-client -zr "recipe[apache]"
[2020-03-10T02:46:00+00:00] WARN: No config file found or specified on command line. Using command line options instead.
Starting Chef Infra Client, version 15.7.32
resolving cookbooks for run list: ["apache"]
Synchronizing Cookbooks:
  - apache (0.1.0)
Installing Cookbook Gems:
Compiling Cookbooks...
Converging 3 resources
Recipe: apache::server
  * yum_package[httpd] action install (up to date)
  * file[/var/www/html/index.html] action create (up to date)
  * service[httpd] action start (up to date)
  * service[httpd] action enable (up to date)

Running handlers:
Running handlers complete
Chef Infra Client finished, 0/4 resources updated in 01 seconds
```

learning chef resources is far more important than understanding ruby.

### Ohai

the node object is a representation of the system.

```
node['memory']['total']
```

any time you run chef-clientk, ohai is run to provide most up-to-date values for your recipes.

```
[vagrant@localhost ~]$ sudo chef-client -zr "recipe[apache]"
[vagrant@localhost ~]$ curl localhost
<h1>Hello, world!</h1>
  ipaddress: 10.0.2.15
  hostname: localhost
```

### Template

#### Embedded Ruby (ERB)

* `<% xxxxx %>` executes the ruby code within the brackets and do not display the result.
* `<% xxxxx %>` executes the ruby code within the brackets and display the result.

#### Generate Tempalte 

```
[vagrant@localhost ~]$ chef generate template cookbooks/apache index.html
Recipe: code_generator::template
  * directory[cookbooks/apache/templates] action create
    - create new directory cookbooks/apache/templates
    - restore selinux security context
  * template[cookbooks/apache/templates/index.html.erb] action create
    - create new file cookbooks/apache/templates/index.html.erb
    - update content in file cookbooks/apache/templates/index.html.erb from none to e3b0c4
    (diff output suppressed by config)
    - restore selinux security context

[vagrant@localhost ~]$ tree cookbooks/apache/templates/
cookbooks/apache/templates/
└── index.html.erb

0 directories, 1 file
```

## 3. Chef server

### Steps to set up a node

* provision the instance, e.g. aws
* bootstrap the instance, 'knife bootstrap'
* install chef
* copy the cookbook 
* apply the cookbook

### Test deployments with Kitchen

* kitchen create (driver)
    * create virtual machine
* kitchen converge (provisioner)
    * install chef tools
    * copy cookbooks
    * run/apply cookbooks
* kitchen verify (busser)
    * verify assumptions
* kitchen destroy
    * destroy virtual machine


```
gengwg@gengwg-mbp:~/learningchef/cookbooks/apache$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action    Last Error
default-ubuntu-1804  Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
default-centos-7     Vagrant  ChefZero     Inspec    Ssh        <Not Created>  <None>
gengwg@gengwg-mbp:~/learningchef/cookbooks/apache$ kitchen create
gengwg@gengwg-mbp:~/learningchef/cookbooks/apache$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action  Last Error
default-ubuntu-1804  Vagrant  ChefZero     Inspec    Ssh        Created      <None>
default-centos-7     Vagrant  ChefZero     Inspec    Ssh        Created      <None>

gengwg@gengwg-mbp:~/learningchef/cookbooks/apache$ kitchen converge
>>>>>> ------Exception-------
>>>>>> Class: Kitchen::ActionFailed
>>>>>> Message: 2 actions failed.
>>>>>>     Failed to complete #converge action: [Expected process to exit with [0], but received '172'
---- Begin output of chef install /Users/gengwg/learningchef/cookbooks/apache/Policyfile.rb ----
STDOUT: Chef Development Kit cannot execute without accepting the license

===>

gengwg@gengwg-mbp:~/learningchef/cookbooks/apache$ CHEF_LICENSE=accept kitchen converge
gengwg@gengwg-mbp:~/learningchef/cookbooks/apache$ kitchen list
Instance             Driver   Provisioner  Verifier  Transport  Last Action  Last Error
default-ubuntu-1804  Vagrant  ChefZero     Inspec    Ssh        Created      Kitchen::ActionFailed
default-centos-7     Vagrant  ChefZero     Inspec    Ssh        Converged    <None>

gengwg@gengwg-mbp:~/learningchef/cookbooks/apache$ kitchen login default-centos-7
Last login: Wed Mar 11 01:03:14 2020 from 10.0.2.2

This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
[vagrant@default-centos-7 ~]$ curl localhost
<h1>Hello, world!</h1>
<h2>ipaddress: </h2>
<h2>hostname: default-centos-7</h2>
[vagrant@default-centos-7 ~]$ which httpd
/usr/sbin/httpd

gengwg@gengwg-mbp:~/learningchef/cookbooks/apache$ kitchen verify
gengwg@gengwg-mbp:~/learningchef/cookbooks/apache$ kitchen destroy
-----> Starting Test Kitchen (v2.3.4)
-----> Destroying <default-ubuntu-1804>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-ubuntu-1804> destroyed.
       Finished destroying <default-ubuntu-1804> (0m3.83s).
-----> Destroying <default-centos-7>...
       ==> default: Forcing shutdown of VM...
       ==> default: Destroying VM and associated drives...
       Vagrant instance <default-centos-7> destroyed.
       Finished destroying <default-centos-7> (0m3.66s).
-----> Test Kitchen is finished. (0m9.00s)
```

## 4 Going full scale

### Chef Supermarket

https://supermarket.chef.io/

Supermarket is front for github.

### Wrapper cookbooks

* do not use forked community cookbooks in production. 
    * or you will miss out on upstream changes
* instead, use **wrapper cookbooks** to wrap upstream cookbooks and change their behavior w/o forking
* a wrapper cookbook encapsulats the functionality of the original cookbook
* defines new default values for the recipes

```
gengwg@gengwg-mbp:~/learningchef$ chef generate cookbook cookbooks/myhaproxy
Generating cookbook myhaproxy
- Ensuring correct cookbook content

Your cookbook is ready. Type `cd cookbooks/myhaproxy` to enter it.

There are several commands you can run to get started locally developing and testing your cookbook.
Type `delivery local --help` to see a full list of local testing commands.

Why not start by writing an InSpec test? Tests for the default recipe are stored at:

test/integration/default/default_test.rb

If you'd prefer to dive right in, the default recipe can be found at:

recipes/default.rb

gengwg@gengwg-mbp:~/learningchef$ vim cookbooks/myhaproxy/metadata.rb
depends 'haproxy', '= 1.6.7'
```

### Resolve dependencies with Berkshelf

## Server Artifacts

### Roles

* describes a run list of recipes that are executed on teh node

```
roles/web.rb

name 'web'
description 'Web server'
run_list 'recipe[apache]'
```

### Environments

### Data bags

https://learn.chef.io/#/

