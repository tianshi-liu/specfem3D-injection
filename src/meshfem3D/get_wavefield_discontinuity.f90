!! Setting up the surface on which wavefield discontinuity condition is
!! imposed
!! Tianshi Liu, 2023.5

subroutine write_wavefield_discontinuity_database()
  use constants, only: IIN_DB
  use wavefield_discontinuity_par
  implicit none
  write(IIN_DB) nb_wd
  write(IIN_DB) boundary_to_ispec_wd
  write(IIN_DB) side_wd
  !deallocate(boundary_to_ispec_wd, side_wd)
end subroutine write_wavefield_discontinuity_database

subroutine write_wavefield_discontinuity_file()
  use wavefield_discontinuity_par
  implicit none
  integer :: i
  open(unit=IFILE_WAVEFIELD_DISCONTINUITY, &
       file='MESH/wavefield_discontinuity_boundary', &
       form='formatted', action='write')
  do i = 1, nb_wd
    write(IFILE_WAVEFIELD_DISCONTINUITY, *) boundary_to_ispec_wd(i), side_wd(i)
  enddo
  close(IFILE_WAVEFIELD_DISCONTINUITY)
end subroutine write_wavefield_discontinuity_file

subroutine find_wavefield_discontinuity_elements()
  use constants, only: CUSTOM_REAL
  use meshfem_par, only: xstore,ystore,zstore,nspec
  use wavefield_discontinuity_par
  implicit none
  integer :: boundary_to_ispec_wd_temp(6*nspec), side_wd_temp(6*nspec)
  integer :: ispec, iside, i, j, k
  logical :: is_boundary_wd
  logical :: covered(26)
  double precision :: x_min, x_max, y_min, y_max, z_min, z_max
  double precision :: dx, dy, dz, x_mid, y_mid, z_mid, ratio_small=1.0e-6
  open(unit=IFILE_WAVEFIELD_DISCONTINUITY, &
       file='wavefield_discontinuity_box', &
       form='formatted', action='read')
  read(IFILE_WAVEFIELD_DISCONTINUITY, *) x_min
  read(IFILE_WAVEFIELD_DISCONTINUITY, *) x_max
  read(IFILE_WAVEFIELD_DISCONTINUITY, *) y_min
  read(IFILE_WAVEFIELD_DISCONTINUITY, *) y_max
  read(IFILE_WAVEFIELD_DISCONTINUITY, *) z_min
  read(IFILE_WAVEFIELD_DISCONTINUITY, *) z_max
  close(IFILE_WAVEFIELD_DISCONTINUITY)
  nb_wd = 0
  do ispec = 1, nspec
    covered(:) = .false.
    x_mid = xstore(2,2,2,ispec)
    y_mid = ystore(2,2,2,ispec)
    z_mid = zstore(2,2,2,ispec)
    dx = ratio_small * abs(xstore(3,1,1,ispec) - xstore(1,1,1,ispec))
    dy = ratio_small * abs(ystore(1,3,1,ispec) - ystore(1,1,1,ispec))
    dz = ratio_small * abs(zstore(1,1,3,ispec) - zstore(1,1,1,ispec))
    !! bottom
    iside = 21; i = 2; j = 2; k = 1
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/9,10,11,12,1,2,3,4,21/)) = .true.
      endif
    endif
    !! front
    iside = 22; i = 2; j = 1; k = 2
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/9,13,14,17,1,2,5,6,22/)) = .true.
      endif
    endif
    !! right
    iside = 23; i = 3; j = 2; k = 2
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/10,14,15,18,2,3,6,7,23/)) = .true.
      endif
    endif
    !! back
    iside = 24; i = 2; j = 3; k = 2
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/11,15,16,19,3,4,7,8,24/)) = .true.
      endif
    endif
    !! left
    iside = 25; i = 1; j = 2; k = 2
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/12,13,16,20,1,4,5,8,25/)) = .true.
      endif
    endif
    !! top
    iside = 26; i = 2; j = 2; k = 3
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/17,18,19,20,5,6,7,8,26/)) = .true.
      endif
    endif
    !! front - bottom
    iside = 9; i = 2; j = 1; k = 1
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/1,2,9/)) = .true.
      endif
    endif
    !! right - bottom
    iside = 10; i = 3; j = 2; k = 1
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/2,3,10/)) = .true.
      endif
    endif
    !! back - bottom
    iside = 11; i = 2; j = 3; k = 1
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/3,4,11/)) = .true.
      endif
    endif
    !! left - bottom
    iside = 12; i = 1; j = 2; k = 1
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/1,4,12/)) = .true.
      endif
    endif
    !! left - front
    iside = 13; i = 1; j = 1; k = 2
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/1,5,13/)) = .true.
      endif
    endif
    !! right - front
    iside = 14; i = 3; j = 1; k = 2
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/2,6,14/)) = .true.
      endif
    endif
    !! right - back
    iside = 15; i = 3; j = 3; k = 2
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/3,7,15/)) = .true.
      endif
    endif
    !! left - front
    iside = 16; i = 1; j = 3; k = 2
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/4,8,16/)) = .true.
      endif
    endif
    !! front - top
    iside = 17; i = 2; j = 1; k = 3
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/5,6,17/)) = .true.
      endif
    endif
    !! right - top
    iside = 18; i = 3; j = 2; k = 3
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/6,7,18/)) = .true.
      endif
    endif
    !! back - top
    iside = 19; i = 2; j = 3; k = 3
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/7,8,19/)) = .true.
      endif
    endif
    !! left - bottom
    iside = 20; i = 1; j = 2; k = 3
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered((/5,8,20/)) = .true.
      endif
    endif
    !! left - front - bottom
    iside = 1; i = 1; j = 1; k = 1
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered(1) = .true.
      endif
    endif
    !! right - front - bottom
    iside = 2; i = 3; j = 1; k = 1
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered(2) = .true.
      endif
    endif
    !! right - back - bottom
    iside = 3; i = 3; j = 3; k = 1
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered(3) = .true.
      endif
    endif
    !! left - front - bottom
    iside = 4; i = 1; j = 3; k = 1
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered(4) = .true.
      endif
    endif
    !! left - front - top
    iside = 5; i = 1; j = 1; k = 3
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered(5) = .true.
      endif
    endif
    !! right - front - top
    iside = 6; i = 3; j = 1; k = 3
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered(6) = .true.
      endif
    endif
    !! right - back - top
    iside = 7; i = 3; j = 3; k = 3
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered(7) = .true.
      endif
    endif
    !! left - front - top
    iside = 8; i = 1; j = 3; k = 3
    if (.not. covered(iside)) then
      if (is_boundary_wd(xstore(i,j,k,ispec), ystore(i,j,k,ispec), &
                       zstore(i,j,k,ispec), x_min, x_max, y_min, y_max, &
                       z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                       IS_TOP_WAVEFIELD_DISCONTINUITY)) then
        nb_wd = nb_wd + 1
        boundary_to_ispec_wd_temp(nb_wd) = ispec
        side_wd_temp(nb_wd) = iside
        covered(8) = .true.
      endif
    endif
  enddo
  allocate(boundary_to_ispec_wd(nb_wd), side_wd(nb_wd))
  boundary_to_ispec_wd(1:nb_wd) = boundary_to_ispec_wd_temp(1:nb_wd)
  side_wd(1:nb_wd) = side_wd_temp(1:nb_wd)
end subroutine find_wavefield_discontinuity_elements

logical function is_boundary_wd(x, y, z, x_min, x_max, y_min, y_max, &
                                z_min, z_max, x_mid, y_mid, z_mid, dx, dy, dz, &
                                IS_TOP_WAVEFIELD_DISCONTINUITY)
  implicit none
  double precision :: x_min, x_max, y_min, y_max, z_min, z_max
  double precision :: x, y, z, x_mid, y_mid, z_mid, dx, dy, dz
  logical :: IS_TOP_WAVEFIELD_DISCONTINUITY
  is_boundary_wd = .false.
  if (((x < x_min + dx) .or. (x > x_max - dx) .or. &
       (y < y_min + dy) .or. (y > y_max - dy) .or. &
       (z < z_min + dz) .or. ((z > z_max - dz) .and. &
       IS_TOP_WAVEFIELD_DISCONTINUITY)) .and. &
       (x_mid > x_min) .and. (x_mid < x_max) .and. &
       (y_mid > y_min) .and. (y_mid < y_max) .and. &
       (z_mid > z_min) .and. ((.not. IS_TOP_WAVEFIELD_DISCONTINUITY) .or. &
       (z_mid < z_max))) &
    is_boundary_wd = .true.
end function is_boundary_wd