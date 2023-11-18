return function(_p)
	local network = {}
	local LocalPlayer = _p.player

	local function logNetworkExploit(func)
		LocalPlayer:Kick("Please avoid exploiting. Further exploitation will result in a ban.")
	end

	function network:bindEvent()
		logNetworkExploit("bindEvent")
	end

	function network:bindFunction()
		logNetworkExploit("bindFunction")
	end

	function network:post()
		logNetworkExploit("post")
	end

	function network:postAll()
		logNetworkExploit("postAll")
	end

	function network:get()
		logNetworkExploit("get")
	end

	return network
end
