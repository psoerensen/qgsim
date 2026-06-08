subroutine qgsim_gene_drop_fortran(hap1, hap2, parent_count, marker_count, &
    sire, dam, offspring_count, marker_map, starts, offsets, crossovers, &
    paternal, maternal, genotype)
  implicit none
  integer, intent(in) :: parent_count, marker_count, offspring_count
  integer, intent(in) :: hap1(parent_count, marker_count)
  integer, intent(in) :: hap2(parent_count, marker_count)
  integer, intent(in) :: sire(offspring_count), dam(offspring_count)
  double precision, intent(in) :: marker_map(marker_count)
  integer, intent(in) :: starts(2 * offspring_count)
  integer, intent(in) :: offsets(2 * offspring_count + 1)
  double precision, intent(in) :: crossovers(*)
  integer, intent(out) :: paternal(offspring_count, marker_count)
  integer, intent(out) :: maternal(offspring_count, marker_count)
  integer, intent(out) :: genotype(offspring_count, marker_count)
  integer :: offspring, marker, gamete, haplotype, crossover_index
  integer :: crossover_end

  do offspring = 1, offspring_count
    gamete = offspring
    haplotype = starts(gamete)
    crossover_index = offsets(gamete) + 1
    crossover_end = offsets(gamete + 1)

    do marker = 1, marker_count
      do while (crossover_index <= crossover_end)
        if (crossovers(crossover_index) > marker_map(marker)) exit
        haplotype = 3 - haplotype
        crossover_index = crossover_index + 1
      end do
      if (haplotype == 1) then
        paternal(offspring, marker) = hap1(sire(offspring), marker)
      else
        paternal(offspring, marker) = hap2(sire(offspring), marker)
      end if
    end do

    gamete = offspring_count + offspring
    haplotype = starts(gamete)
    crossover_index = offsets(gamete) + 1
    crossover_end = offsets(gamete + 1)

    do marker = 1, marker_count
      do while (crossover_index <= crossover_end)
        if (crossovers(crossover_index) > marker_map(marker)) exit
        haplotype = 3 - haplotype
        crossover_index = crossover_index + 1
      end do
      if (haplotype == 1) then
        maternal(offspring, marker) = hap1(dam(offspring), marker)
      else
        maternal(offspring, marker) = hap2(dam(offspring), marker)
      end if
      genotype(offspring, marker) = paternal(offspring, marker) + &
        maternal(offspring, marker)
    end do
  end do
end subroutine qgsim_gene_drop_fortran
