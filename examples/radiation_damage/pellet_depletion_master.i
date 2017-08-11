[Mesh]
 type = CartesianMesh
 dim = 2
 dx = '0.2 0.2 0.1 0.02 0.01 0.005 0.005 0.005 0.005 0.01 0.02 0.02 0.05 0.06'
 dy = '0.5 0.5'
 subdomain_id = '1 1 1 1 1 1 1 2 2 2 2 2 2 2
                 1 1 1 1 1 1 1 2 2 2 2 2 2 2'
[]

[Problem]
  coord_type = RZ
[]

[GlobalParams]
 plus = true
 isMeter = false
 isotopes = 'pseudo'
 densities = 1.0
 MGLibObject = PinLib
 grid_names = 'Burnup Tfuel Dmod Boron'
 grid_variables = 'burnup_MWd/kg temperature density_liquid boron'
[]

[TransportSystems]
  particle = neutron
  equation_type = eigenvalue
  G = 8
  [./diffusion]
    scheme = CFEM-Diffusion
  [../]
[]

[Depletion]
  transport_system = diffusion
  power_modulating_function = const_func

  burnup_unit = MWd/kg
  depletion_material_names = 'fuel'
  postprocessor_output = 'average_burnup'

  # assuming power density of p = 250 W / cm3 => P = V * p converted to MW
  rated_power = 0.00023

  total_fuel_volume = 0.916061
  fuel_density = 10.950
  isotopes = 'U235 U238'
  weight_percentages = '5.0 95.0'
[]

[AuxVariables]
  [./temperature]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 566.0
  [../]
  [./boron]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 500.0
  [../]
  [./density_liquid]
    initial_condition = 749.59
  [../]
  [./fission_rate]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./N92235]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.02
  [../]
  [./N92238]
    order = CONSTANT
    family = MONOMIAL
    initial_condition = 0.32
  [../]
[]

[AuxKernels]
  [./fission_rate]
    type = ReactionRate
    cross_section = 'xs_g7 xs_g6 xs_g5 xs_g4 xs_g3 xs_g2 xs_g1 xs_g0'
    scalar_flux = 'sflux_g7 sflux_g6 sflux_g5 sflux_g4 sflux_g3 sflux_g2 sflux_g1 sflux_g0'
    variable = fission_rate
  [../]
[]

[Functions]
  [./const_func]
    type = ConstantFunction
    value = 1.0
  [../]

  [./partial_fission_rate]
    type = ParsedFunction
    value = '1e-12 * s * theta_i * Ni'
    vars = 's theta_i Ni'
    vals = 'power_scaling fission_rate N92235'
  [../]
[]

[YAKXSLibraries]
  [./PinLib]
     type = BaseLibObject
     library_file = '../../../../problems/pwr_station_blackout/RattleSnake_BISON_RELAP7/8G/X-Section/TAKAHAMA3-PIN-8G-ENDFB-R5.xml'
     library_name = TAKAHAMA3-PIN-8G-ENDFB-R5
     library_type = MultigroupLibrary
     library_ids = '1 8'
  [../]
[]

[Materials]
  [./fuel]
    type = CoupledFeedbackNeutronicsMaterial
    block = 1
    material_id = 1
  [../]
  [./water]
    type = CoupledFeedbackNeutronicsMaterial
    block = 2
    material_id = 8
    grid_names = 'Boron Dmod'
    grid_variables = 'boron density_liquid'
    plus = false
  [../]
  [./cross_section]
    type = GenericConstantMaterial
    prop_names = 'xs_g7 xs_g6 xs_g5 xs_g4 xs_g3 xs_g2 xs_g1 xs_g0'
    prop_values = '1.22e+00 1.62e+00 2.02e+01 3.54e+01 1.16e+02 1.84e+02 2.74e+02 5.61e+02'
  [../]
[]

[UserObjects]
  [./fission_damage_sampler]
    type = NeutronicsSpectrumSamplerFission
    points = '0 0 0'

    # Everything is in ascending order
    energy_group_boundaries = '1.00e-11 5.80e-08 1.40e-07 2.80e-07 6.25e-07 4.00e-06 5.53e-03 8.21e-01 1.00e+01'
    target_isotope_names = 'U235 U238'
    number_densities = 'N92235 N92238'
    scalar_fluxes = 'sflux_g7 sflux_g6 sflux_g5 sflux_g4 sflux_g3 sflux_g2 sflux_g1 sflux_g0'
    # each row are the recoil cross sections for a single isotope && all group (g=0,1)
    # I also set a lot of the tiny thermal fission XS for 92238 to zero (slowest five groups E < 6.25e-7) because we have no product data for them
    fission_cross_sections =  '
                              1.22e+00 1.62e+00 2.02e+01 3.54e+01 1.16e+02 1.84e+02 2.74e+02 5.61e+02
                              1.63e-05 9.04e-06 6.16e-06 4.29e-06 2.61e-06 2.37e-04 4.64e-04 3.79e-01
                              '
    execute_on = timestep_end
  [../]
[]

[Postprocessors]
  [./total_power]
    type = ElementIntegralVariablePostprocessor
    variable = total_reactor_power_density
  [../]
  [./volume]
    type = VolumePostprocessor
    block = 1
  [../]
  [./fission_rate]
    type = PointValue
    point = '0 0 0'
    variable = fission_rate
  [../]
  [./partial_fission_rate]
    type = FunctionValuePostprocessor
    function = partial_fission_rate
  [../]
  [./N92235]
    type = PointValue
    variable = N92235
    point = '0 0 0'
    execute_on = TIMESTEP_END
  [../]
  [./N92238]
    type = PointValue
    variable = N92238
    point = '0 0 0'
    execute_on = TIMESTEP_END
  [../]
[]

[MultiApps]
  [./radiation_damage_app]
    type = FullSolveMultiApp
    input_files = damage_sub.i
    positions = '0.0 0.0 0.0'
    execute_on = timestep_end
  [../]
[]

[Transfers]
  [./radiation_damage_transfer]
    type = MultiAppNeutronicsSpectrumTransfer
    multi_app = radiation_damage_app
    pka_neutronics = neutronics_fission_generator
    radiation_damage_sampler = fission_damage_sampler
    direction = to_multiapp
  [../]
[]

[Executioner]
  type = Depletion
  source_abs_tol = 1e-10
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_max_iter'
  petsc_options_value = 'hypre boomeramg 100 2'

  burnup = '0 43200 86400 432000 864000 1728000 2592000 3456000 4320000 5184000 6048000 6912000 7776000 8640000
            9504000 10368000 11232000 12096000 12960000 13824000 14688000 15552000 16416000 17280000 18144000
            19008000 19872000 20736000 21600000 22464000 23328000 24192000 25056000 25920000 26784000 27648000 28512000 29376000
            30240000 31104000 31536000'
[]

[Outputs]
  exodus = true
  csv = true
[]
