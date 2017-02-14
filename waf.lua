local now = ngx.now()
local request_method = ngx.var.request_method
local waf = ngx.shared.waf
local uri = ngx.var.uri
local postctl = ngx.var.postctl or 10
-- also rejecting people using stupid buggy api to achieve double click
if request_method == "POST" and ( string.find(uri, "forum.php") or string.find(uri, "api/mobile/index") ) then
        local remote_hex = ngx.md5(ngx.var.remote_addr .. "_" .. ngx.var.request_uri)
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
