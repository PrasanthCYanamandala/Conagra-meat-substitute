/* Import all meat_substitute data from 2020-2024 */
PROC IMPORT OUT= pj_2020 DATAFILE= "E:\Users\pxy230011\Downloads\class Pred\Fz_Rfg Substitute Meat_POS_2020.xlsx" 
            DBMS=xlsx REPLACE;

     SHEET="test"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= pj_2021 DATAFILE= "E:\Users\pxy230011\Downloads\class Pred\Fz_Rfg Substitute Meat_POS_2021.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="test"; 
     GETNAMES=YES;
RUN;
PROC IMPORT OUT= pj_2022 DATAFILE= "E:\Users\pxy230011\Downloads\class Pred\Fz_Rfg Substitute Meat_POS_2022.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="test"; 
     GETNAMES=YES;
RUN;PROC IMPORT OUT= pj_2023 DATAFILE= "E:\Users\pxy230011\Downloads\class Pred\Fz_Rfg Substitute Meat_POS_2023.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="test"; 
     GETNAMES=YES;
RUN;PROC IMPORT OUT= pj_2024 DATAFILE= "E:\Users\pxy230011\Downloads\class Pred\Fz_Rfg Substitute Meat_POS_2024.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="test"; 
     GETNAMES=YES;
RUN;
/*vertically stacks 2022 and 2023 data into one dataset*/
data pj_combined;
set pj_2020 pj_2021 pj_2022 pj_2023 pj_2024;
by; run;
proc print data= pj_combined; run;
/* attaches manufacturer name to POS data*/
PROC IMPORT OUT= pj_productData DATAFILE= "E:\Users\pxy230011\Downloads\class Pred\Product Attributes.xlsx" 
            DBMS=xlsx REPLACE;
     SHEET="Rfg_and_Fz_Meat_and_Substitute"; 
     GETNAMES=YES;
RUN;
proc sql;
	create table pj_manufact as
		select a.*, b.Manufacturer_Name from pj_combined as a
		inner join pj_productData as b on a.UPC_13_digit=b.UPC_13_digit;
quit;
/*trim data to US level and other regions */
data pj_totus;
set pj_manufact;
IF Geography^= 'Total US - Multi Outlet + Conv' THEN delete;
run;
data pj_other;
set pj_manufact;
IF Geography= 'Total US - Multi Outlet + Conv' THEN delete;
run;
proc print data= pj_other(obs=20); run;
data pj_other;
set pj_other;
if Geography = "California - Standard - Multi Outlet + Conv" then Gcali = 1;
else Gcali = 0;
if Geography = "Great Lakes - Standard - Multi Outlet + Conv" then Ggl = 1;
else Ggl = 0;
if Geography = "Mid-South - Standard - Multi Outlet + Conv" then Gms = 1;
else Gms = 0;
if Geography = "Northeast - Standard - Multi Outlet + Conv" then Gne = 1;
else Gne = 0;
if Geography = "Plains - Standard - Multi Outlet + Conv" then Gp = 1;
else Gp = 0;
if Geography = "South Central - Standard - Multi Outlet + Conv" then Gsc = 1;
else Gsc = 0;
if Geography = "Southeast - Standard - Multi Outlet + Conv" then Gse = 1;
else Gse = 0;
if Geography = "West - Standard - Multi Outlet + Conv" then Gw = 1;
else Gw = 0;
run;
data pj_all;
set pj_manufact;
if Geography = "California - Standard - Multi Outlet + Conv" then Gcali = 1;
else Gcali = 0;
if Geography = "Great Lakes - Standard - Multi Outlet + Conv" then Ggl = 1;
else Ggl = 0;
if Geography = "Mid-South - Standard - Multi Outlet + Conv" then Gms = 1;
else Gms = 0;
if Geography = "Northeast - Standard - Multi Outlet + Conv" then Gne = 1;
else Gne = 0;
if Geography = "Plains - Standard - Multi Outlet + Conv" then Gp = 1;
else Gp = 0;
if Geography = "South Central - Standard - Multi Outlet + Conv" then Gsc = 1;
else Gsc = 0;
if Geography = "Southeast - Standard - Multi Outlet + Conv" then Gse = 1;
else Gse = 0;
if Geography = "West - Standard - Multi Outlet + Conv" then Gw = 1;
else Gw = 0;
if Geography = "Total US - Multi Outlet + Conv" then Gt = 1;
else Gt = 0;
run;
/* Brand Level */
data pj_brandedtotus;
set pj_totus;
length Brand $11;
Brand='Other';
IF Manufacturer_Name= 'KELLANOVA' then Brand='MorningStar';
IF Manufacturer_Name= 'BEYOND MEAT INC' then Brand='Beyond';
IF Manufacturer_Name= 'IMPOSSIBLE FOODS INC' then Brand='Impossible';
If Manufacturer_Name= 'CONAGRA BRANDS' then Brand='Gardein';
If Manufacturer_Name= 'LIGHTLIFE FOODS INC' then Brand='Lightlife';
time=scan(time,3,' ');
eow=input(time, mmddyy9.);
format eow mmddyy9.;
run;
data pj_brandedother;
set pj_other;
length Brand $11;
Brand='Other';
IF Manufacturer_Name= 'KELLANOVA' then Brand='MorningStar';
IF Manufacturer_Name= 'BEYOND MEAT INC' then Brand='Beyond';
IF Manufacturer_Name= 'IMPOSSIBLE FOODS INC' then Brand='Impossible';
If Manufacturer_Name= 'CONAGRA BRANDS' then Brand='Gardein';
If Manufacturer_Name= 'LIGHTLIFE FOODS INC' then Brand='Lightlife';
time=scan(time,3,' ');
eow=input(time, mmddyy9.);
format eow mmddyy9.;
run;
data pj_brandedall;
set pj_all;
length Brand $11;
Brand='Other';
IF Manufacturer_Name= 'KELLANOVA' then Brand='MorningStar';
IF Manufacturer_Name= 'BEYOND MEAT INC' then Brand='Beyond';
IF Manufacturer_Name= 'IMPOSSIBLE FOODS INC' then Brand='Impossible';
If Manufacturer_Name= 'CONAGRA BRANDS' then Brand='Gardein';
If Manufacturer_Name= 'LIGHTLIFE FOODS INC' then Brand='Lightlife';
time=scan(time,3,' ');
eow=input(time, mmddyy9.);
format eow mmddyy9.;
run;
/* data exploration */
proc print data=pj_brandedtotus; run;
proc print data=pj_brandedother(obs=50); run;
/* select variables */
proc corr data= pj_brandedtotus;
var Unit_Sales Unit_Sales_No_Merch Unit_Sales_Any_Merch 
Volume_Sales Volume_Sales_No_Merch Volume_Sales_Any_Merch 
Dollar_Sales Dollar_Sales_Any_Merch Dollar_Sales_No_Merch 
ACV_Weighted_Distribution ACV_Weighted_Distribution_No_Mer ACV_Weighted_Distribution_Any_Me
Incremental_Units Incremental_Volume;
run;
/* Linear regression */
proc sort data=pj_brandedall; by brand time; run;
proc sort data=pj_brandedother; by brand product time; run;
/* Market Share */
proc sql outobs=5;
	select manufacturer_name as name, (sum(dollar_sales)/(select sum(dollar_sales) from pj_brandedall))*100 as percMS
	from pj_brandedall
	where name^='PRIVATE LABEL'
	group by name
	order by percMS desc;
quit;
proc reg data= pj_brandedother;
by brand;
MODEL Unit_Sales_Any_Merch = Unit_Sales_No_Merch Volume_Sales_No_Merch
Volume_Sales_Any_Merch ACV_Weighted_Distribution_Any_Me Incremental_Units
Dollar_Sales_Any_Merch Ggl Gms Gne Gp Gsc Gse Gw / STB; run; quit;
proc reg data= pj_brandedother;
MODEL Unit_Sales_Any_Merch = Unit_Sales_No_Merch Volume_Sales_No_Merch
Volume_Sales_Any_Merch ACV_Weighted_Distribution_Any_Me Incremental_Units
Dollar_Sales_Any_Merch Ggl Gms Gne Gp Gsc Gse Gw / STB; run; quit;
proc sort data=pj_brandedall; by brand product time; run;
proc reg data= pj_brandedother
outest=reg_coeff;
by brand product;
MODEL Unit_Sales_Any_Merch = Unit_Sales_No_Merch Volume_Sales_No_Merch
Volume_Sales_Any_Merch ACV_Weighted_Distribution_Any_Me Incremental_Units
Dollar_Sales_Any_Merch Gcali Ggl Gms Gne Gp Gsc Gse Gw / STB; run; quit;

proc rank data=reg_coeff
out=ranked_products
ties=high;
by brand;
var Dollar_Sales_Any_Merch ;
ranks merchandising_rank;
run;
proc print data=ranked_products;
where brand = 'Gardein'; run;
proc sort data=ranked_products; by brand merchandising_rank; run;

