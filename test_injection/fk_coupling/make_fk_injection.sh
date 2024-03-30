mpif90 -g -o compute_fk_injection_field coupling_fk.f90 utils.f90 compute_fk_injection_field.f90

mpif90 -g -o compute_fk_receiver coupling_fk.f90 utils.f90 compute_fk_receiver.f90
