module RawMutex

const shim = joinpath(dirname(@__FILE__), "..", "deps", "libshimuv.so")
Libdl.dlopen(shim, Libdl.RTLD_GLOBAL)

const UV_BARRIER_SIZE = ccall(:sizeof_uv_barrier_t, Cint, ())
const UV_MUTEX_SIZE = ccall(:jl_sizeof_uv_mutex, Cint, ())

typealias Mutex Ptr{Void}
typealias Barrier Ptr{Void}

function create_mutex()
  m = Libc.malloc(UV_MUTEX_SIZE)
  ccall(:uv_mutex_init, Void, (Ptr{Void},), m)
  return m
end

function create_barrier(count)
  b = Libc.malloc(UV_BARRIER_SIZE)
  err = ccall(:uv_barrier_init, Cint, (Ptr{Void}, Cuint), b, count)
  err != 0 && error("uv error code", err)
  return b
end

function close_mutex(m::Mutex)
    if m != C_NULL
        ccall(:uv_mutex_destroy, Void, (Ptr{Void},), m)
        Libc.free(m)
        nothing
    end
end

function close_barrier(b::Barrier)
  if b != C_NULL
    ccall(:uv_barrier_destroy, Void, (Ptr{Void},), b)
    Libc.free(b)
    nothing
  end
end

function trylock(m::Mutex)
    r = ccall(:uv_mutex_trylock, Cint, (Ptr{Void},), m)
    return r == 0
end

function unlock(m::Mutex)
    ccall(:uv_mutex_unlock, Void, (Ptr{Void},), m)
    return
end

function lock(m::Mutex)
  ccall(:uv_mutex_lock, Void, (Ptr{Void},), m)
end

function wait(b::Barrier)
  ccall(:uv_barrier_wait, Cint, (Ptr{Void},), b)
  nothing
end

end # module
