use <case-shape.scad>

module basic_case_shape() { // make me
  basic_shape_of_case(build=true);
}

module case_shape() { // make me - deps: basic_case_shape
  case(build=true);
}

