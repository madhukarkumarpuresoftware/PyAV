from cpython cimport PyBuffer_FillInfo, PyBUF_FORMAT, PyBUF_ND, PyBUF_STRIDES, PyBUF_WRITABLE

from av.video.frame cimport VideoFrame


cdef class VideoPlane(Plane):
    def __cinit__(self, VideoFrame frame, int index):
        for i in range(frame.format.ptr.nb_components):
            if frame.format.ptr.comp[i].plane == index:
                self.component = frame.format.components[i]
                break
        else:
            raise RuntimeError('could not find plane %d of %r' % (index, frame.format))

        # Sometimes, linesize is negative (and that is meaningful). We are only
        # insisting that the buffer size be based on the extent of linesize, and
        # ignore it's direction.
        self.buffer_size = abs(self.frame.ptr.linesize[self.index]) * self.component.height

        # Setup buffer shape
        bits_per_pixel = 0
        for i in range(frame.format.ptr.nb_components):
            if frame.format.ptr.comp[i].plane == index:
                bits_per_pixel += self.component.bits
        assert bits_per_pixel % 8 == 0
        self.shape[0] = self.component.height
        self.shape[1] = self.component.width * (bits_per_pixel // 8)

        self.strides[0] = abs(self.frame.ptr.linesize[self.index])
        self.strides[1] = 1

    def __getbuffer__(self, Py_buffer *view, int flags):
        if flags & PyBUF_WRITABLE and not self._buffer_writable():
            raise ValueError('buffer is not writable')

        view.obj = self
        view.buf = self._buffer_ptr()
        view.len = self._buffer_size()
        view.readonly = not self._buffer_writable()
        view.itemsize = 1
        view.format = NULL
        if ((flags & PyBUF_FORMAT) == PyBUF_FORMAT):
            view.format = 'B'
        view.ndim = 2
        view.shape = NULL
        if ((flags & PyBUF_ND) == PyBUF_ND):
            view.shape = self.shape
        view.strides = NULL
        if ((flags & PyBUF_STRIDES) == PyBUF_STRIDES):
            view.strides = self.strides
        view.suboffsets = NULL
        view.internal = NULL

    cdef size_t _buffer_size(self):
        return self.buffer_size

    property line_size:
        """
        Bytes per horizontal line in this plane.

        :type: int
        """
        def __get__(self):
            return self.frame.ptr.linesize[self.index]

    property width:
        """Pixel width of this plane."""
        def __get__(self):
            return self.component.width

    property height:
        """Pixel height of this plane."""
        def __get__(self):
            return self.component.height
