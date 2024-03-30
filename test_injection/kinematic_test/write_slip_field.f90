program write_slip_field
  use mpi
  implicit none
  integer, parameter :: CUSTOM_REAL = 4
  integer, parameter :: THREE = 3
  integer, parameter :: NGLLSQUARE = 25
  double precision, parameter :: SOURCE_DECAY_MIMIC_TRIANGLE = 1.628d0
  integer :: ier, ip, ib, igll, nlines, nb, np
  character(len=256) :: fn, line
  real(kind=CUSTOM_REAL), dimension(:), allocatable :: xp, yp, zp
  real(kind=CUSTOM_REAL), dimension(:), allocatable :: sxp, syp, szp
  real(kind=CUSTOM_REAL), dimension(:), allocatable :: xb, yb, zb, nxb, nyb, nzb
  real(kind=CUSTOM_REAL), dimension(:), allocatable :: jcbw, sxb, syb, szb
  real(kind=CUSTOM_REAL), dimension(:,:), allocatable :: displ, traction
  real(kind=CUSTOM_REAL) :: mxy, mxy_total, mu =  2600.0 * 3198.0 * 3198.0
  integer :: myrank

  integer :: it, nstep = 5200
  double precision :: t, dt = 0.02, hdur = 2.0, t0 = 8.0, val

  double precision, external :: comp_source_time_function, &
                                comp_source_time_function_dgau

  call MPI_Init(ier)
  if (ier /= 0 ) stop 'Error initializing MPI'
  call MPI_Comm_rank(MPI_COMM_WORLD, myrank, ier)

  !myrank = 59

  write(fn, "('DATABASES_MPI/proc',i6.6,'_wavefield_discontinuity_points')")&
      myrank
  open(77, file=trim(fn), action="read")
  ier = 0
  nlines = 0
  do while (ier == 0)
    read(77, '(a)', iostat=ier) line
    if (ier == 0) nlines = nlines + 1
  enddo
  close(77)
  np = nlines
  allocate(xp(np), yp(np), zp(np), sxp(np), syp(np), szp(np))
  !allocate(displ(THREE, np), accel(THREE, np))
  !displ(:,:) = 0.0
  !accel(:,:) = 0.0
  open(77, file=trim(fn), action="read")
  do ip = 1, np
    read(77, *) xp(ip), yp(ip), zp(ip)
  enddo
  close(77)
  write(fn, "('DATABASES_MPI/proc',i6.6,'_wavefield_discontinuity_faces')")&
    myrank
  open(77, file=trim(fn), action="read")
  ier = 0
  nlines = 0
  do while (ier == 0)
    read(77, '(a)', iostat=ier) line
    if (ier == 0) nlines = nlines + 1
  enddo
  close(77)
  nb = nlines / NGLLSQUARE
  allocate(xb(nb*NGLLSQUARE), yb(nb*NGLLSQUARE), &
           zb(nb*NGLLSQUARE), nxb(nb*NGLLSQUARE), nyb(nb*NGLLSQUARE), &
           nzb(nb*NGLLSQUARE), jcbw(nb*NGLLSQUARE), &
           sxb(nb*NGLLSQUARE), syb(nb*NGLLSQUARE), szb(nb*NGLLSQUARE))
  !allocate(traction(THREE, NGLLSQUARE, nb))
  !traction(:,:,:) = 0.0
  open(77, file=trim(fn), action="read")
  do ip = 1, nb*NGLLSQUARE
  !  do igll = 1, NGLLSQUARE
    read(77, *) xb(ip), yb(ip), zb(ip), &
                  nxb(ip), nyb(ip), nzb(ip), jcbw(ip)
  !  enddo
  enddo
  close(77)

  call compute_slip(xp, yp, zp, sxp, syp, szp, np)

  call compute_slip(xb, yb, zb, sxb, syb, szb, nb*NGLLSQUARE)

  mxy = sum(sxb*nyb*jcbw) + sum(syb*nxb*jcbw)
  call MPI_REDUCE(mxy, mxy_total, 1, MPI_FLOAT, MPI_SUM, 0, MPI_COMM_WORLD, ier)
  if (myrank == 0) then
    mxy_total = mxy_total * mu
    print *, 'mxy = ', mxy_total
  endif

  allocate(displ(THREE, np), traction(THREE, nb*NGLLSQUARE))
  displ(1,:) = sxp(:)
  displ(2,:) = syp(:)
  displ(3,:) = szp(:)
  traction(:,:) = 0.0

  write(fn, "('DATABASES_MPI/proc',i6.6,'_wavefield_discontinuity.bin')")&
      myrank
  open(88, file=trim(fn), form="unformatted", action="write")

  if (myrank==0) open(77, file='stf.txt', form='formatted', action='write')
  if (myrank==0) open(66, file='stfdd.txt', form='formatted', action='write')
  hdur = hdur / SOURCE_DECAY_MIMIC_TRIANGLE
  do it = 1, nstep
    t = (it-1) * dt - t0
    val = comp_source_time_function(t, hdur)
    if (myrank==0) write(77, *) t, val
    write(88) displ(:,:) * sngl(val)
    val = comp_source_time_function_dgau(t, hdur)
    if (myrank==0) write(66, *) t, val
    write(88) displ(:,:) * sngl(val)
    write(88) traction(:,:)
  enddo   
  if (myrank==0) close(77)
  if (myrank==0) close(66)
  close(88)

  deallocate(xp, yp, zp, xb, yb, zb, nxb, nyb, nzb, jcbw, sxb, syb, szb)
  deallocate(displ, traction)

  call MPI_Finalize(ier)
end program write_slip_field

subroutine compute_slip(x, y, z, sx, sy, sz, n)
  implicit none
  integer, parameter :: CUSTOM_REAL = 4
  real, parameter :: eps = 1.0
  integer :: n, i
  real(kind=CUSTOM_REAL) :: x(n), y(n), z(n), sx(n), sy(n), sz(n)
  real(kind=CUSTOM_REAL) :: yp, zp
  real :: peak_slip = 3.0 ! m
  real :: sigma1 = 2500.0, sigma2 = 15000.0, &
          x0 = 100000.0, y0 = 100000.0, z0 = -8750.0
  real :: y1 = 60000.0, y2 = 140000.0, z1 = -15000.0, z2 = 0.0
  do i = 1, n
    yp = y(i); zp = z(i)
    if ((yp <= y1 + eps) .or. (yp >= y2 - eps) .or. &
        (zp <= z1 + eps) .or. (zp >= z2 - eps)) then
      sy(i) = 0.0
    else
      sy(i) = peak_slip * exp(- ((yp-y0)/sigma2)**2 - ((zp-z0)/sigma1)**2)
    endif
  enddo
  sx(:) = 0.0
  sz(:) = 0.0
end subroutine compute_slip
