content pagination previous=introduction/running_malamute_view_results.md
                    next=introduction/concluding_remarks.md
                    margin-bottom=0px

This tutorial was created with the intention of providing initial instructions for MALAMUTE by exploring the relation between temperature and die wall thickness. After visualizing in Excel, the +Temperature vs Time+ data for each wall thickness, we see that the overall temperature decreases as the wall thickness increases. One exception to this pattern is the similar temperature values approximately halfway through the linear portion (approximately t = 1240 s to t = 1260 s) of the “cooling process”. Also, as the die wall thickness increases, the time at which max temperature occurs is higher. 

!media /media/temp_vs_sim_time.png
       style=width:80%;margin-left:auto;margin-right:auto;
       id=temp_vs_sim_time
       caption=Temperature vs Time data for each of the five wall thicknesses

The electric potential on the toolset steadily decreases from the top of the toolset to the bottom of it, as observed in [potential_temp_screenshot]. This indicates that the direction of electric current is from top to bottom, and this current direction corresponds with how the DCS-5 machine is constructed. 

!media /media/potential_temp_screenshot.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=potential_temp_screenshot
    caption=Electrical Potential and Temperature Contour Plots.

There is a sizable difference between each of the max temperature values for the various die wall thicknesses and a slight difference at the time which these max temperatures occur, as shown in [max_temp_vs_sim_time]. This occurrence might be explained by the electric field contour plots shown in [5mm_elec_field_and_temp]. 

!media /media/max_temp_vs_sim_time.png
       style=width:100%;margin-left:auto;margin-right:auto;
       id=max_temp_vs_sim_time
       caption=Max Temperature vs Simulation Time.

Regarding the contour plots at max temperature formed by ParaView, we observed patterns regarding temperature and electric potential. The graphite die wall thickness increase leads to a cooler temperature of the powder and die wall as shown by the ‘temperature’ contour plot, in [here] for example. The temperature difference due to die wall thickness is visualized in the figures below by a sharp color shade difference between the 5 mm (pic 1) and 25 mm (pic 2) die thickness contour plots. Also, this color change and thus gradual temperature decrease is seen progressively across all five die wall thickness examples. Especially if viewing the contour plots starting from the 5 mm die wall thickness temperature contour plot, then ending with the 25 mm die wall thickness temperature contour plot. Also, the center of the graphite plungers is generally hotter than the die wall and the powder casing, with an almost white color having an approximate value of 2.3e+03 K. 

Electric field values slightly between different wall thickness, but noticeably changes on the graphite spacers. The electric field is highly concentrated in the center of these graphite spacers and seems to correspond with the higher temperature values in the same spot. This phenomenon is most clearly shown in [5mm_elec_field_and_temp]. However, the powder casing and die wall do not experience a similar spike in temperature or electric potential and may need to be considered when analyzing an EFAS toolset.

!media /media/5mm_elec_field_and_temp.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=5mm_elec_field_and_temp
    caption=Electric Field and Temperature Contour Plots for a 5 mm wall thickness at t = 954 seconds.

!media /media/10mm_elec_field_and_temp.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=5mm_elec_field_and_temp
    caption=Electric Field and Temperature Contour Plots for a 10 mm wall thickness at t = 960 seconds.

!media /media/13.875mm_elec_field_and_temp.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=13.875mm_elec_field_and_temp
    caption=Electric Field and Temperature Contour Plots for a 13.875 mm wall thickness at t = 960 seconds.

!media /media/20mm_elec_field_and_temp.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=20mm_elec_field_and_temp
    caption=Electric Field and Temperature Contour Plots for a 20 mm wall thickness at t = 966 seconds.

!media /media/25mm_elec_field_and_temp.png
    style=width:80%;margin-left:auto;margin-right:auto;
    id=25mm_elec_field_and_temp
    caption=Electric Field and Temperature Contour Plots for a 25 mm wall thickness at t = 972 seconds.

