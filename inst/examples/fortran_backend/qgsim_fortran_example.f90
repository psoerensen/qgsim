subroutine qgsim_fortran_update(n, values, increment)
  implicit none
  integer, intent(in) :: n
  double precision, intent(inout) :: values(n)
  double precision, intent(in) :: increment
  integer :: i

  do i = 1, n
    values(i) = values(i) + increment
  end do
end subroutine qgsim_fortran_update
