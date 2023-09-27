/****************************************************************************/
/*                        DO NOT MODIFY THIS HEADER                         */
/*                                                                          */
/* MALAMUTE: MOOSE Application Library for Advanced Manufacturing UTilitiEs */
/*                                                                          */
/*           Copyright 2021 - 2023, Battelle Energy Alliance, LLC           */
/*                           ALL RIGHTS RESERVED                            */
/****************************************************************************/

#include "ADGaussianHeatSourceBase.h"

InputParameters
ADGaussianHeatSourceBase::validParams()
{
  InputParameters params = Material::validParams();
  params.addRequiredParam<Real>("power", "laser power (1e-3 W)");
  params.addParam<Real>("efficiency", 1, "process efficiency");
  params.addParam<bool>("use_input_r",
                        true,
                        "option to use user input effective radii or from experimentally fitted "
                        "formulations. Default is to use user input data.");
  params.addParam<std::vector<Real>>("r",
                                     {},
                                     "effective radii (mm) along three directions. If only one "
                                     "parameter is provided, then we assume "
                                     "the effective radius to be equal along three directions.");

  params.addParam<Real>(
      "feed_rate",
      0.0,
      "powder material feed rate (g/ms). This value is used only when use_input_r = false.");

  params.addParam<Real>(
      "factor",
      1.0,
      "scaling factor that is multiplied to the heat source to adjust the intensity");

  params.addParam<Real>("std_factor", 1.0, "factor to the std to sample r");

  params.addParam<MooseEnum>(
      "heat_source_type", MooseEnum("point line mixed", "point"), "Type of the heat source");

  params.addParam<Real>("threshold_length",
                        1.0,
                        "Threshold size (mm) when we change the way of computing heat source");

  params.addParam<Real>(
      "number_time_integration",
      10,
      "Number of points to do time integration for averaged heat source calculation");

  params.declareControllable("power efficiency r factor");

  params.addClassDescription("Gaussian volumetric source heat source base.");

  return params;
}

ADGaussianHeatSourceBase::ADGaussianHeatSourceBase(const InputParameters & parameters)
  : Material(parameters),
    _use_input_r(getParam<bool>("use_input_r")),
    _P(getParam<Real>("power")),
    _eta(getParam<Real>("efficiency")),
    _feed_rate(getParam<Real>("feed_rate")),
    _r(getParam<std::vector<Real>>("r")),
    _f(getParam<Real>("factor")),
    _std_factor(getParam<Real>("std_factor")),
    _heat_source_type(getParam<MooseEnum>("heat_source_type").getEnum<HeatSourceType>()),
    _threshold_length(getParam<Real>("threshold_length")),
    _number_time_integration(getParam<Real>("number_time_integration")),
    _volumetric_heat(declareADProperty<Real>("volumetric_heat"))
{
  if (_use_input_r)
  {
    if (_r.size() != 1 && _r.size() != 3)
      paramError("r", "The effective radii should have 1 or 3 components.");
    // make sure we have 3 equal components if only one parameter is provided
    if (_r.size() == 1)
    {
      _r.push_back(_r[0]);
      _r.push_back(_r[0]);
    }
  }
  else
  {
    _r.resize(3);
    // Since the LINE and MIXED types averages over _t-_dt ->_t,
    // _r info for the previous steps & sub_steps are needed
    // however, this info is not available, and sampling again would change the
    // history
    if (_heat_source_type != HeatSourceType::POINT)
      paramError("heat_source_type",
                 "We can only use the POINT heat source type when _use_input_r = false.");
  }

  // set to a small number to start
  _r_time_prev = -1.0e8;
}

void
ADGaussianHeatSourceBase::computeQpProperties()
{
  const Real & x = _q_point[_qp](0);
  const Real & y = _q_point[_qp](1);
  const Real & z = _q_point[_qp](2);

  switch (_heat_source_type)
  {
    case HeatSourceType::POINT:
      _volumetric_heat[_qp] = computeHeatSourceAtTime(x, y, z, _t);
      break;
    case HeatSourceType::LINE:
      _volumetric_heat[_qp] = computeAveragedHeatSource(x, y, z, _t - _dt, _t);
      break;
    case HeatSourceType::MIXED:
      _volumetric_heat[_qp] = computeMixedHeatSource(x, y, z, _t - _dt, _t);
      break;
  }
}

Real
ADGaussianHeatSourceBase::computeHeatSourceAtTime(const Real x,
                                                  const Real y,
                                                  const Real z,
                                                  const Real time)
{
  // center of the heat source
  Real x_t, y_t, z_t;
  computeHeatSourceCenterAtTime(x_t, y_t, z_t, time);

  Real dist_x = -2.0 * std::pow(x - x_t, 2.0) / _r[0] / _r[0];
  Real dist_y = -2.0 * std::pow(y - y_t, 2.0) / _r[1] / _r[1];
  Real dist_z = -2.0 * std::pow(z - z_t, 2.0) / _r[2] / _r[2];

  // Gaussian point heat source
  return 2.0 * _P * _eta * _f / libMesh::pi / _r[0] / _r[1] / _r[2] *
         std::exp(dist_x + dist_y + dist_z);
}

Real
ADGaussianHeatSourceBase::computeAveragedHeatSource(
    const Real x, const Real y, const Real z, const Real time_begin, const Real time_end)
{
  mooseAssert(time_end > time_begin, "Begin time should be smaller than end time.");
  // Use 5 points as a starting point. Number of points will double if
  // integration is not accurate enough or exceeds _number_time_integration.
  unsigned int num_pts = 5;
  Real Q_integral = 0, Q_integral_old = 0;
  do
  {
    Q_integral_old = Q_integral;
    Real delta_t = (time_end - time_begin) / num_pts;
    Real t0 = time_begin;
    Real Q_begin = computeHeatSourceAtTime(x, y, z, time_begin);
    Real Q_end;
    Q_integral = 0;
    for (unsigned int i = 0; i < num_pts; ++i)
    {
      t0 += delta_t;
      Q_end = computeHeatSourceAtTime(x, y, z, t0);
      // compute integral of Q between t0 and t0 + delta_t
      Q_integral += (Q_begin + Q_end) * delta_t / 2.0;
      // update Q_begin
      Q_begin = Q_end;
    }
    num_pts *= 2;
    // limit to _number_time_integration pts to accelerate the simulation
    if (num_pts > _number_time_integration)
      break;
  } while (!MooseUtils::absoluteFuzzyEqual(Q_integral_old, Q_integral, 1e-4));

  return Q_integral / (time_end - time_begin);
}

Real
ADGaussianHeatSourceBase::computeMixedHeatSource(
    const Real x, const Real y, const Real z, const Real time_begin, const Real time_end)
{
  mooseAssert(time_end > time_begin, "Begin time should be smaller than end time.");

  // position at time_begin
  Real x_t0, y_t0, z_t0;
  computeHeatSourceCenterAtTime(x_t0, y_t0, z_t0, time_begin);
  Point P_start = Point(x_t0, y_t0, z_t0);
  // position at time_end
  Real x_t, y_t, z_t;
  computeHeatSourceCenterAtTime(x_t, y_t, z_t, time_end);
  Point P_end = Point(x_t, y_t, z_t);

  Real SE = (P_end - P_start).norm();
  if (SE < _threshold_length)
    return computeHeatSourceAtTime(x, y, z, time_end);
  else
    return computeAveragedHeatSource(x, y, z, time_begin, time_end);
}

void
ADGaussianHeatSourceBase::computeProperties()
{
  // effective radii under current processing parameters
  if (!_use_input_r)
  {
    // compute scanning speed at this time
    computeHeatSourceMovingSpeedAtTime(_t);
    // compute the effective radii
    computeEffectiveRadii(_t);
  }

  Material::computeProperties();
}

void
ADGaussianHeatSourceBase::computeEffectiveRadii(const Real time)
{
  // we do not update _r if we do not proceed in time
  if (time <= _r_time_prev)
    return;
  else
    _r_time_prev = time;

  // get scaled laser power, scanning speed, and powder feed rate
  Real lp = _P / 1.0e-3 / 400.0;             // input in unit 1e-3 W
  Real ss = _scan_speed / 4.23333e-4 / 40.0; // input in mm/ms (1 ipm = 4.23333e-4 mm/ms)
  Real pf = _feed_rate / 0.031e-3 / 15.0;    // input in g/ms (1rpm = 0.031e-3 g/ms)

  // list of the variable values
  std::vector<Real> vals = {lp, ss, pf, lp * lp, ss * ss, pf * pf, lp * ss, lp * pf, ss * pf, 1.0};

  Real mean_rxy = 0.0, mean_rz = 0.0;
  Real std_r = 0.0;
  _r[2] = 0.0;
  for (unsigned int i = 0; i < vals.size(); ++i)
  {
    // compute the mean and standard deviation of the melt pool dimension (x and y dimensions)
    mean_rxy += _diameter_param[i].first * vals[i];
    std_r += _diameter_param[i].second * vals[i];
    // compute the material bead height (z dimension)
    mean_rz += _height_param[i] * vals[i];
  }

  // sample the r[0] and r[2] value
  // define a random number generator
  std::random_device rd{};
  std::mt19937 generator{rd()};
  std::normal_distribution<double> dist_xy(mean_rxy, std_r);
  std::normal_distribution<double> dist_z(mean_rz, std_r);
  _r[0] = dist_xy(generator);
  _r[2] = dist_z(generator);
  // make sure that the sampled values are within +-sigma range
  if (_r[0] > mean_rxy + _std_factor * std::abs(std_r))
    _r[0] = mean_rxy + _std_factor * std::abs(std_r);
  else if (_r[0] < mean_rxy - _std_factor * std::abs(std_r) || _r[0] <= 0.0)
    _r[0] = std::abs(mean_rxy - _std_factor * std::abs(std_r)); // make sure r is not negative
  _r[0] *= 0.5;                                                 // get the radius
  _r[1] = _r[0];

  if (_r[2] > mean_rz + _std_factor * std::abs(std_r))
    _r[2] = mean_rz + _std_factor * std::abs(std_r);
  else if (_r[2] < mean_rz - _std_factor * std::abs(std_r) || _r[0] <= 0.0)
    _r[2] = std::abs(mean_rz - _std_factor * std::abs(std_r)); // make sure r is not negative
}
