console = {
    print_string = '',
    input_string = '',
    write_prompt = false,
}

local socket = require('socket')

function console:init()
    -- create the server bound to an OS assigned port
    self.server = assert(socket.bind('*', 0))
    self.server:settimeout(0, 'b')
    
    -- record the IP and port
    self.ip, self.port = self.server:getsockname()
    
    -- clear the client
    self.client = nil
end

function console:update()
    if self.write_prompt then
        self:writemsg('lua> ')
        self.write_prompt = false
    end
    
    -- check for a client if not already attached
    local new_client = nil
    if not self.client then
        -- accept returns nil on failure
        new_client = self.server:accept()
    end
    
    -- just got a new client
    if new_client and not self.client then
        self.client = new_client
        self.client:settimeout(0)
    end
    
    -- client update
    if self.client then
        local r_arr, w_arr, sel_err = socket.select({self.client}, {self.client}, 0)
        if not sel_err then
            -- send
            if w_arr[1] and '' ~= self.print_string then
                w_arr[1]:send(self.print_string)
                self.print_string = ''
            end
            
            -- recv
            if r_arr[1] then
                local pat, err, dat = r_arr[1]:receive()
                if dat then
                    self.input_string = self.input_string .. dat
                end
                if not err then
                    assert(loadstring(self.input_string))()
                    self.input_string = ''
                    self.write_prompt = true
                end
            end
        end
    end
end

function console:writemsg(msg)
    self.print_string = self.print_string .. msg
end

-- override print
function print(msg)
    console.write_prompt = true
    console:writemsg(msg .. '\r\n')
end

console:init()
