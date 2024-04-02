dir=snapshot
#seq -w 000200 200 002000 | while read step
seq -w 000100 100 004000 | while read step
do
for comp in X Y Z
#for comp in X
do
  ./bin/xcombine_vol_data_vtk 0 39 displ_${comp}_it${step} DATABASES_MPI/ $dir/ 0
done
done
