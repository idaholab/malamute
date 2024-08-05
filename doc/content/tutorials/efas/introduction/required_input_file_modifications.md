!content pagination previous=introduction/content.md
                    next=introduction/running_malamute_view_results.md

## Required Input File Modifications

Two sections that may require editing is in Line 55’s `die_wall_thickness`variable and the `pyrometer_point` block. The value for die wall thickness must be written in meters, not millimeters. The impact of die wall thickness on the temperature read by the pyrometer is explored in this tutorial. 

### Die Wall Thickness

We performed a study to observe the temperature of the powder as the die wall thickness changes. The only value (in meters) changed in the input files was in Line 55:

```
die_wall_thickness = (value here)
```

 We will create a separate input file for each thickness change. The [suggested_input_file_names] below shows suggested names for the five separate input files for each die wall thickness. 

!table id=suggested_input_file_names caption=Input file name suggestions for the five different die wall thicknesses.
| Case | die_wall_thickness | Suggested Input File Name |
| :- | :- | :- |
| 1 | 5 mm | dcs5_5_mm_dt_6_copper_constant_properties_electrothermal.i |
| 2 | 10 mm | dcs5_10_mm_dt_6_copper_constant_properties_electrothermal.i |
| 3 | 13.875 mm | dcs5_13.875_mm_dt_6_copper_constant_properties_electrothermal.i |
| 4 | 20 mm | dcs5_20_mm_dt_6_copper_constant_properties_electrothermal.i |
| 5 | 25 mm | dcs5_25_mm_dt_6_copper_constant_properties_electrothermal.i |

These five separate input files were created so these five different MALAMUTE runs could process at the same moment and thus save time compared to running these input files separately. 

### Pyrometer Point

One concern we held was how to accurately represent the distance of the pyrometer inside the die wall. The first equation in `[Postprocessors]`, which includes `fparse powder_radius`, details the length at which the pyrometer is inserted into the die wall. 

!listing tutorials/efas/introduction/dcs5_copper_constant_properties_electrothermal.i
         block=Postprocessors/ pyrometer_point
         link=False

The `0.004` value in the equation mentioned above has units of meters and was calculated with the following steps. This `0.004` value is the distance from the edge of the powder casing to the tip of the inserted pyrometer. In our studies we noticed, the size of the graphite toolset affected the radius of the powder casing. The radius of the powder casing is constant in this example, but in future studies, this equation: `${fparse powder_radius + 0.004}` may require modification based on the graphite toolset used.

!content pagination previous=introduction/content.md
                    next=introduction/running_malamute_view_results.md
                    margin-bottom=0px
