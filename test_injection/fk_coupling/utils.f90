  subroutine flush_IMAIN()

  use fk_injection, only: IMAIN

  implicit none

  ! only main process writes out to main output file
  ! file I/O in Fortran is buffered by default
  !
  ! note: Fortran2003 includes a FLUSH statement
  !          which is implemented by most compilers by now
  !
  ! otherwise:
  !   a) comment out the line below
  !   b) try to use instead: call flush(IMAIN)

  flush(IMAIN)

  end subroutine flush_IMAIN

! version without rank number printed in the error message

  subroutine exit_MPI_without_rank(error_msg)

  use mpi
  !use fk_injection

  implicit none

  character(len=*) :: error_msg
  integer :: ier

  ! write error message to screen
  write(*,*) error_msg(1:len(error_msg))
  write(*,*) 'Error detected, aborting MPI...'

  ! flushes possible left-overs from print-statements
  call flush_stdout()

  ! abort execution
  call MPI_ABORT(MPI_COMM_WORLD,30,ier)
  stop 'error, program ended in abort_mpi'

  end subroutine exit_MPI_without_rank

  subroutine flush_stdout()

! flushes possible left-overs from print-statements

  implicit none

  logical :: is_connected

  ! note: Cray systems don't flush print statements before ending with an MPI
  ! abort,
  !       which often omits debugging statements with print before it.
  !
  !       to check which unit is used for standard output, one might also use a
  !       Fortran2003 module iso_Fortran_env:
  !         use, intrinsic :: iso_Fortran_env, only: output_unit

  ! checks default stdout unit 6
  inquire(unit=6,opened=is_connected)
  if (is_connected) &
    flush(6)

  ! checks Cray stdout unit 101
  inquire(unit=101,opened=is_connected)
  if (is_connected) &
    flush(101)

  end subroutine flush_stdout
