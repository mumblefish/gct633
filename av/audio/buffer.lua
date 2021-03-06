--[[
A generic audio buffer object, whose length is fixed from birth.
Stores a sequence of frames of samples. Each frame has 1 or more channels.
	i.e. multi-channel audio is interleaved. 
64-bit currently.

Uses: 
	- writing audio data to disk.
	- reading audio data from disk.
	- simplifying RtAudio handling
	- passing between ugens
	- generating wavetables
	- using in delay lines

A fancier buffer class would use arr2, then it can support arbitary interleave steps.

Check out ByteArray for ideas. 

--]]

local min, max = math.min, math.max
local format = string.format

local ffi = require "ffi"
ffi.cdef [[

	typedef struct audio_buffer {
		int frames, channels;
		double samples [?];
	} audio_buffer;
	
]]

function new(frames, channels) 
	assert(frames and frames > 0, "buffer length (frames) required")
	channels = channels and (max(channels, 1)) or 1
	local buf = ffi.new("audio_buffer", frames*channels, frames, channels)
	print(buf, buf.frames, buf.channels)
	return buf
end

local buffer = {}
buffer.__index = buffer

function buffer:__tostring()
	return format("audio.buffer(%dx%d, %p)", self.frames, self.channels, self)
end

--[[
-- TODO buffer methods:

buffer:apply(func)
(plus some standard ones built in:
buffer:zero
buffer:normalize(amp)
buffer:fadeout|in?

buffer.fill(func)
buffer.fill(standard table name)
or buffer[standard table name] lazy constructor?

-- buffer provides only minimal indexing functions;
-- use a sampler (wrapper) for fancier stuff.
buffer:at
buffer:read (interp)

buffer.resample
buffer.setchannels

function buffer:save(filename) end
function buffer.load(filename) end

--]]


ffi.metatype("audio_buffer", buffer)

setmetatable(buffer, {
	__call = function(s, frames, channels)
		return new(frames, channels)
	end,
})


return buffer

