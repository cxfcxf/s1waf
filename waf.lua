local now = ngx.now()
local request_method = ngx.var.request_method
local waf = ngx.shared.waf
local uri = ngx.var.uri
local postctl = ngx.var.postctl or 10
if request_method == "POST" and ( string.find(uri, "forum.php") or string.find(uri, "api/mobile/index") ) then
        local remote_hex = ngx.md5(ngx.var.remote_addr .. "_" .. ngx.var.uri)
        -- ngx.log(ngx.ERR, remote_hex)
        local lastpost, flags = waf:get(remote_hex)
        if lastpost then
                difftime = now - lastpost
                if difftime <= tonumber(postctl) then
                        return ngx.redirect(ngx.var.http_referer)
                else
                        local succ, err, forcible = waf:set(remote_hex, now)
                        if err then
                                ngx.log(ngx.ERR, "failed to store last post info: ", err)
                        end
                end

        else
                local succ, err, forcible = waf:set(remote_hex, now)
                if err then
                        ngx.log(ngx.ERR, "failed to store last post info: ", err)
                end
        end
end

if request_method == "POST" then
        local inlist, flags = waf:get(ngx.var.remote_addr)
        if inlist then
                ngx.exit(ngx.HTTP_FORBIDDEN)
        end
end

if request_method == "HEAD" and string.find(uri, "waf_blacklist.php") and ngx.var.req.remote_addr == "remote_script_address" then
        local args = ngx.req.get_uri_args()
        local succ, err, forcible = waf:set(args["ip"], true)
        if err then
                ngx.log(ngx.ERR, "failed to store blacklist: ", err)
        end
        ngx.exit(ngx.HTTP_OK)
end
