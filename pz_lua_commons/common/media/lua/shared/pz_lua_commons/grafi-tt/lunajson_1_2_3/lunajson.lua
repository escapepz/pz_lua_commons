local newdecoder = require("pz_lua_commons/grafi-tt/lunajson_1_2_3/decoder")
local newencoder = require("pz_lua_commons/grafi-tt/lunajson_1_2_3/encoder")
-- If you need multiple contexts of decoder and/or encoder,
-- you can require lunajson.decoder and/or lunajson.encoder directly.
return {
	decode = newdecoder(),
	encode = newencoder(),
}
