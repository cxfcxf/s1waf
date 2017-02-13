### simple waf for discuz to prevent duplicating post submit

# we can also decode body to get formhash, which might be more percise as a hex key components

#how to
in nginx.conf
* 1. set a lua shared DICT called waf inside nginx
* 2. initialize a variable called $postctl
```
set $postctl 10  <- 10 sec between posts
```
* 3. initialize access control
```
access_by_lua_file waf.lua;
```

#a reload is required each time you change $postctl value inside nginx.conf
