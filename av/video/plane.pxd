from av.plane cimport Plane
from av.video.format cimport VideoFormatComponent


cdef class VideoPlane(Plane):

    cdef VideoFormatComponent component

    cdef readonly size_t buffer_size
    cdef Py_ssize_t shape[2]
    cdef Py_ssize_t strides[2]
