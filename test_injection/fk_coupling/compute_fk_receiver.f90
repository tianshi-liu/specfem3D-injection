program compute_fk_receiver
  use fk_injection
  implicit none
  integer, parameter :: THREE = 3
  character(len=256) :: fn, line
  character(len=3) :: char_comp = 'XYZ'
  integer :: ier, ip, np, nlines, ic
  real(kind=CUSTOM_REAL), dimension(:), allocatable :: xp, yp, zp
  real(kind=CUSTOM_REAL), dimension(:,:,:), allocatable :: seismogram
  character(len=256), dimension(:), allocatable :: nt_name, sta_name
  real(kind=CUSTOM_REAL) :: ray_p,Tg,DF_FK

  real(kind=CUSTOM_REAL) :: rho_tmp,kappa_tmp,mu_tmp,alpha_tmp,beta_tmp,xi
  integer :: ii, kk, iim1, iip1, iip2, it_tmp
  real(kind=CUSTOM_REAL) :: cs1,cs2,cs3,cs4,w

  real(kind=CUSTOM_REAL), parameter :: TOL_ZERO_TAKEOFF = 1.e-14

  real(kind=CUSTOM_REAL) :: zmid, ztop
  real(kind=CUSTOM_REAL) :: time_t

  fn = "DATA/STATIONS"
  open(77, file=trim(fn), action="read")
  ier = 0
  nlines = 0
  do while (ier == 0)
    read(77, '(a)', iostat=ier) line
    if (ier == 0) nlines = nlines + 1
  enddo
  close(77)
  np = nlines
  allocate(xp(np), yp(np), zp(np), nt_name(np), sta_name(np))
  open(77, file=trim(fn), action="read")
  do ip = 1, np
    read(77, *) sta_name(ip), nt_name(ip), yp(ip), xp(ip), zp(ip)
  enddo
  close(77)
  
  call ReadFKModelInput()

  ! converts origin point Z to reference framework depth for FK,
  ! where top of lower half-space has to be at z==0
  zz0 = zz0 - Z_REF_for_FK

  ! converts to rad
  phi_FK   = phi_FK * PI/180.d0    ! azimuth
  theta_FK = theta_FK * PI/180.d0  ! take-off

  ! ray parameter p (according to Snell's law: sin(theta1)/v1 ==
  ! sin(theta2)/v2)
  if (type_kpsv_fk == 1) then
    ! P-wave
    ray_p = sin(theta_FK)/alpha_FK(nlayer)    ! for vp (i.e., alpha)
  else if (type_kpsv_fk == 2) then
    ! SV-wave
    ray_p = sin(theta_FK)/beta_FK(nlayer)     ! for vs (i.e., beta)
  endif

  ! note: vertical incident (theta==0 -> p==0) is not handled.
  !       here, it limits ray parameter p to a very small value to handle
  !       the calculations
  if (abs(ray_p) < TOL_ZERO_TAKEOFF) ray_p = sign(TOL_ZERO_TAKEOFF,ray_p)

  ! maximum period
  Tg  = 1.d0 / ff0

  call find_size_of_working_arrays(deltat, freq_sampling_fk, tmax_fk, &
                                   NF_FOR_STORING, &
                                   NF_FOR_FFT, NPOW_FOR_INTERP, NP_RESAMP, &
                                   DF_FK)

  ! user output
  if (myrank == 0) then
    write(IMAIN,*) '  computed FK parameters:'
    write(IMAIN,*) '    frequency sampling rate        = ', freq_sampling_fk,"(Hz)"
    write(IMAIN,*) '    number of frequencies to store = ', NF_FOR_STORING
    write(IMAIN,*) '    number of frequencies for FFT  = ', NF_FOR_FFT
    write(IMAIN,*) '    power of 2 for FFT             = ', NPOW_FOR_INTERP
    write(IMAIN,*)
    write(IMAIN,*) '    simulation time step           = ', deltat,"(s)"
    write(IMAIN,*) '    total simulation length        = ', NSTEP*deltat,"(s)"
    write(IMAIN,*)
    write(IMAIN,*) '    FK time resampling rate        = ', NP_RESAMP
    write(IMAIN,*) '    new time step for F-K          = ', NP_RESAMP * deltat,"(s)"
    write(IMAIN,*) '    new time window length         = ', tmax_fk,"(s)"
    write(IMAIN,*)
    write(IMAIN,*) '    frequency step for F-K         = ', DF_FK,"(Hz)"
    call flush_IMAIN()
  endif

  ! safety check with number of simulation time steps
  if (NSTEP/NP_RESAMP > NF_FOR_STORING + NP_RESAMP) then
    if (myrank == 0) then
      print *,'Error: FK time window length ',tmax_fk,' and NF_for_storing ',NF_FOR_STORING
      print *,'       are too small for chosen simulation length with NSTEP = ',NSTEP
      print *
      print *,'       you could use a smaller NSTEP <= ',NF_FOR_STORING*NP_RESAMP
      print *,'       or'
      print *,'       increase FK window length larger than ',(NSTEP/NP_RESAMP -NP_RESAMP) * NP_RESAMP * deltat
      print *,'       to have a NF for storing  larger than ',(NSTEP/NP_RESAMP -NP_RESAMP)
    endif
    stop 'Invalid FK setting'
  endif

  ! limits resampling sizes
  if (NP_RESAMP > 10000) then
    if (myrank == 0) then
      print *,'Error: FK resampling rate ',NP_RESAMP,' is too high for frequencysampling rate ',freq_sampling_fk
      print *,'       and the chosen simulation DT = ',deltat
      print *
      print *,'       you could use a higher frequency sampling rate>',1./(10000*deltat)
      print *,'       (or increase the time stepping size DT if possible)'
    endif
    stop 'Invalid FK setting'
  endif

  allocate(displ(THREE, np, -NP_RESAMP:NF_FOR_STORING+NP_RESAMP), &
           accel(THREE, np, -NP_RESAMP:NF_FOR_STORING+NP_RESAMP))

  allocate(xx(np), yy(np), zz(np))
  xx(:) = xp(:); yy(:) = yp(:); zz(:) = zp(:) - Z_REF_for_FK
  call FK(alpha_FK, beta_FK, mu_FK, h_FK, nlayer, &
          Tg, ray_p, phi_FK, xx0, yy0, zz0, &
          tt0, deltat, nstep, np, &
          type_kpsv_fk, NF_FOR_STORING, NPOW_FOR_FFT,  NP_RESAMP, DF_FK, &
          .false.)
  deallocate(xx, yy, zz)

  allocate(seismogram(THREE, np, NSTEP))
  do it_tmp = 1,NSTEP
        ! FK coupling
        !! find indices
        ! example:
        !   np_resamp = 1 and it = 1,2,3,4,5,6, ..
        !   --> ii = 1,2,3,4,5,6,..
        !   np_resamp = 2 and it = 1,2,3,4,5,6, ..
        !   --> ii = 1,1,2,2,3,3,..
    ii = floor( real(it_tmp + NP_RESAMP - 1) / real( NP_RESAMP))
        ! example:
        !       kk = 1,2,1,2,1,2,,..
    kk = it_tmp - (ii-1) * NP_RESAMP
        ! example:
        !       w = 0,1/2,0,1/2,..
    w = dble(kk-1) / dble(NP_RESAMP)

    ! Cubic spline values
    cs4 = w*w*w/6.d0
    cs1 = 1.d0/6.d0 + w*(w-1.d0)/2.d0 - cs4
    cs3 = w + cs1 - 2.d0*cs4
    cs2 = 1.d0 - cs1 - cs3 - cs4

    ! interpolation indices
    iim1 = ii-1        ! 0,..
    iip1 = ii+1        ! 2,..
    iip2 = ii+2        ! 3,..

    seismogram(:,:,it_tmp) = cs1*displ(:,:,iim1)+cs2*displ(:,:,ii)+&
                             cs3*displ(:,:,iip1)+cs4*displ(:,:,iip2)
  enddo

  do ip = 1, np
    do ic = 1, THREE
      fn = "OUTPUT_FILES/"//trim(nt_name(ip))//'.'//trim(sta_name(ip)) &
           //'.'//char_comp(ic:ic)//".fkd"
      open(77, file=trim(fn), action='write')
      do it_tmp = 1, NSTEP
        time_t = (it_tmp-1) * deltat - tt0
        write(77, *) time_t, seismogram(ic, ip, it_tmp)
      enddo
      close(77)
    enddo
  enddo
  deallocate(xp, yp, zp, nt_name, sta_name, displ, accel, seismogram)
end program compute_fk_receiver
