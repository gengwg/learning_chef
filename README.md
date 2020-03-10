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

## Test and repair

chef-client takes action only when it needs to. chef looks at the current state of each resource and takes action only when that resource is out of policy.

## Cookbook

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

## Including a recipe: include_recipe

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
