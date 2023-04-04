/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#pragma once

#include "Material.h"
#include "MooseEnum.h"
#include <random>

/**
 * Double ellipsoid heat source distribution.
 */
class GaussianHeatSourceBase : public Material
{
public:
  static InputParameters validParams();

  GaussianHeatSourceBase(const InputParameters & parameters);

protected:
  virtual void computeHeatSourceCenterAtTime(Real & x, Real & y, Real & z, const Real & time) = 0;

  virtual void computeProperties() override;

  virtual void computeQpProperties() override;

  virtual void computeHeatSourceMovingSpeedAtTime(const Real & time) = 0;

  Real computeHeatSourceAtTime(const Real x, const Real y, const Real z, const Real time);

  Real computeAveragedHeatSource(
      const Real x, const Real y, const Real z, const Real time_begin, const Real time_end);

  Real computeMixedHeatSource(
      const Real x, const Real y, const Real z, const Real time_begin, const Real time_end);

  /// compute the effective radii based on the current processing parameters
  void computeEffectiveRadii(const Real time);

  /// whether we use user input effective radii or from experimentally fitted formulations
  const bool & _use_input_r;
  /// power
  const Real & _P;
  /// process efficienty
  const Real & _eta;
  /// material feed rate (used only when _use_input_r=false)
  const Real & _feed_rate;
  /// effective radii along three directions ()
  std::vector<Real> _r;
  /// scaling factor
  const Real & _f;
  /// factor for sampling the standard deviation
  const Real & _std_factor;

  /// heat source moving speed (scalar)
  Real _scan_speed;

  /// type of heat source
  const enum class HeatSourceType { POINT, LINE, MIXED } _heat_source_type;

  const Real _threshold_length;

  const Real _number_time_integration;

  ADMaterialProperty<Real> & _volumetric_heat;

  Real _r_time_prev; // save the time when we last update the effective radii

private:
  // list of the mean and std of the fitted parameters in the diameter formulation
  const std::vector<std::pair<Real, Real>> _diameter_param = {
      {0.95314595, -0.59208523},
      {-0.49753426, 0.07574844},
      {0.49324569, 0.13325939},
      {0.65076134, 0.59117914},
      {0.27564355, -0.03832367},
      {0.0904344, -0.15581355},
      {-0.19017983, -0.15591489},
      {-1.43025713, -0.05721184},
      {0.43584285, 0.1346863},
      {0.15990260757458563, 0.14783244560036998}};

  // list of the fitted parameters in the height formulation
  const std::vector<Real> _height_param = {-0.01697178,
                                           -0.61333238,
                                           0.31978383,
                                           0.15406738,
                                           0.891539,
                                           -0.32619461,
                                           -0.78659714,
                                           1.18223877,
                                           -0.55376121,
                                           0.19044780180084175};
};
