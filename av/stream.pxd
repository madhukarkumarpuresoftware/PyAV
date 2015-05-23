cimport libav as lib
from av.packet cimport Packet
from av.container cimport Container
from av.frame cimport Frame
from libc.stdint cimport int64_t

cdef class Stream(object):
    
    # Stream attributes.
    cdef void* _container
    
    cdef lib.AVStream *_stream
    cdef readonly dict metadata

    # CodecContext attributes.
    cdef lib.AVCodecContext *_codec_context
    cdef lib.AVCodec *_codec
    cdef lib.AVDictionary *_codec_options
    
    # Private API.
    cdef _init(self, Container, lib.AVStream*)
    cdef _setup_frame(self, Frame)
    cdef _decode_one(self, lib.AVPacket*, int *data_consumed)

    # Public API.
    cpdef decode(self, Packet packet)


cdef Stream build_stream(Container, lib.AVStream*)
