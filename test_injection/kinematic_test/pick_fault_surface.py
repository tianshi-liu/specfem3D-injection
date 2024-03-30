import numpy as np
import os

fn_mesh = 'MESH/mesh_file'
fn_coords = 'MESH/nodes_coords_file'
fn_out = 'wavefield_discontinuity_boundary'
x0 = 100000.0
y1 = 100000.0 - 40000.0
y2 = 100000.0 + 40000.0
z2 = -0.0
z1 = -15000.0
eps = 1.0


with open(fn_mesh, 'r') as f_mesh:
  n_element = f_mesh.readline()

n_element = int(n_element)

mesh_nodes = np.loadtxt(fn_mesh, dtype=int, skiprows=1)

if not n_element == len(mesh_nodes):
    print('element number not consistent')
    exit(1)
print('there are ' + str(n_element) + ' elements.')


n_node_per_element = 8
n_node_per_face = 4

face_each_element = [
    [1, 2, 3, 4],
    [1, 5, 6, 2],
    [2, 3, 7, 6],
    [4, 8, 7, 3],
    [1, 4, 8, 5],
    [5, 6, 7, 8]
]

with open(fn_coords, 'r') as f_coords:
  n_vertex = f_coords.readline()

n_vertex = int(n_vertex)

vertex_coords = np.genfromtxt(fname=fn_coords, dtype=[('inode', 'i4'), ('x', 'f8'), ('y', 'f8'), ('z', 'f8')], skip_header=1)

with open(fn_out, 'w') as f_out:
  for elm_nodes in mesh_nodes:
    x_volume_center = np.sum(vertex_coords['x'][elm_nodes[1:] - 1], axis=0) / n_node_per_element
    for iface, face in enumerate(face_each_element):
      x_face_center = np.sum(vertex_coords['x'][elm_nodes[face] - 1], axis=0) / n_node_per_face
      y_face_center = np.sum(vertex_coords['y'][elm_nodes[face] - 1], axis=0) / n_node_per_face
      z_face_center = np.sum(vertex_coords['z'][elm_nodes[face] - 1], axis=0) / n_node_per_face
      if ((abs(x_face_center - x0) < eps) and 
          (y1 < y_face_center < y2) and
          (z1 < z_face_center < z2) and
          (x_volume_center > x0)):
        f_out.write(f"{elm_nodes[0]} {iface + 21}\n")
        print(f"{x_volume_center} {x_face_center} {y_face_center} {z_face_center}\n")
      
