name 'web'
description 'web server role'
run_list 'recipe[apache]', 'recipe[users]'
