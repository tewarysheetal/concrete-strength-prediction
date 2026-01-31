ods html close; 
options nodate nonumber leftmargin=1in rightmargin=1in;
title;
ods graphics on / width=4in height=3in;
ods rtf file='C:\Users\stewary2\OneDrive - University of Illinois - Urbana\Documents\My SAS Files\9.4\dataset\handbook3\Solution\Sheetal Tewary Final Project.rtf' 
	nogtitle startpage=no;
ods noproctitle;
ods text="Concrete Composition & Strength Analysis";
ods text='Introduction';
ods text="This project analyzes a concrete manufacturing dataset containing 1030 concrete samples, each with measured ratios of cementitious and aggregate materials relative to water, age (in days), and compressive strength. For every mix, we observe:
		-cement / water ratio
		-slag / water ratio
		-fly ash / water ratio
		-superplasticizer / water ratio
		-coarse aggregate / water ratio
		-fine aggregate / water ratio
		-age
		-compressive strength (MPa)
The analysis utilizes Analysis of Variance (ANOVA), Multiple Linear Regression, and Linear Discriminant Analysis (LDA) to address the client's specific questions.";
ods text="Overview";
Ods text="Concrete strength is known to vary both with mix composition and curing age, but the magnitude, shape, and interaction of these effects are not always straightforward. The goal of this project is to apply STAT 448–approved statistical methods to answer five key analysis questions:
		1. How do strength levels vary across compositions and age groups?
		2. Can we identify natural clusters of concrete mixes, and do they differ in strength?
		3. Can we predict compressive strength for concrete aged =100 days?
		4. Can we predict whether concrete aged 90–100 days will exceed 50 MPa?
		5. Can mixture composition and strength reliably classify concrete into age groups?";
data concreteratios;
	infile "C:\Users\stewary2\OneDrive - University of Illinois - Urbana\Documents\My SAS Files\9.4\dataset\handbook3\datasets\concreteratios.csv" dlm=",";
	input cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age compressivestrength;
	agegroup= 5;
	if age<28 then agegroup=1;
	if 28<=age<56 then agegroup=2;
	if 56<=age<90 then agegroup=3;
	if 90<=age<180 then agegroup=4;
run;
ods text=" Section 1 — Descriptive Exploration of Strength, Composition, and Age";
ods text="1.1 Summary of Compressive Strength";
ods text="We examined key summary statistics to understand the overall strength behavior in the dataset. Concrete strength shows considerable spread and skewness, indicating different mixture compositions, curing durations, and material contributions.
		*Minimum: 2.3 MPa
		*Maximum: 82.6 MPa
		*Mean: 35.8 MPa
		*Median: 33.6 MPa
		*Standard deviation: 16.7 MPa
		*Distribution type: Right-skewed
		*Most values lie between 20–50 MPa";
proc means data=concreteratios n mean std min median max;
    var cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age compressivestrength;
run;
ods text="1.2 Histogram of Compressive Strength";
ods text="The histogram shows that most mixes fall in the mid-strength range, while a smaller number reach very low or very high strengths. This visual confirms the right-skewed nature observed in the statistics.
		*Main cluster: 20–50 MPa
		*High-strength tail extends to 82.6 MPa
		*Low-strength mixes visible near 5–15 MPa
		*Skew: Right-skewed distribution";
proc univariate data=concreteratios;
    var compressivestrength;
    histogram compressivestrength /normal ;
	ods select histogram;
run;
ods text="1.3 Correlation With Mix Ratios & Age";
ods text="Correlation analysis highlights which materials contribute positively or negatively to strength development. Cement and superplasticizer ratios show strong associations, while fly ash and fine aggregate exhibit mild negative relationships.
		*Cement/water: r ˜ 0.56
		*Superplasticizer/water: r ˜ 0.38
		*Age: r ˜ 0.33
		*Slag/water: r ˜ 0.15–0.20
		*Fly ash/water: r ˜ –0.10
		*Coarse aggregate: r ˜ 0.05
		*Fine aggregate: r ˜ –0.12";
proc corr data=concreteratios nosimple;
    var compressivestrength;
    with cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age;
run;
ods text="1.4 Strength Across Age Groups";
ods text="Strength was compared across five curing age groups to evaluate hydration effects. Strength increases sharply in young concrete and then stabilizes after two to three months as hydration reactions reach completion.
		*Group 1 (<28 days): ~23 MPa
		*Group 2 (28–55 days): ~36 MPa
		*Group 3 (56–89 days): ~52 MPa
		*Group 4 (90–179 days): ~48 MPa
		*Group 5 (=180 days): ~44 MPa
		*Strength plateaus after ~90 days";
proc means data=concreteratios mean median std min max maxdec=2;
    class agegroup;
    var compressivestrength;
run;
proc sgplot data=concreteratios;
    vbox compressivestrength / category=agegroup;
run;
ods text=" Section 2 — Cluster Analysis of Concrete Mixes";
ods text="2.1 Standardization & Ward’s Method";
ods text="Clustering was applied to identify natural groupings of concrete mixtures based on similarity in component ratios and age. Variables were standardized to ensure equal importance in distance calculations.
		*Variables standardized: 7
		*Method used: Ward’s hierarchical clustering
		*Selected clusters: 4
		*Purpose: identify distinct mixture families";
proc standard data=concreteratios mean=0 std=1 out=concrete_std;
    var cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age;
run;
ods graphics on;
ods exclude ClusterHistory ;
proc cluster data=concrete_std method=ward outtree=tree pseudo;
    var cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age;
    copy compressivestrength cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age;
run;
ods exclude none;
ods graphics off;
proc tree data=tree nclusters=4 out=clusters;
    copy compressivestrength cementwater slagwater flyashwater superplasticizerwater coarsewater finewater age;
run;
ods text="2.2 Cluster Profiles";
ods text="Clusters represent different mixture strategies with distinct strength outcomes. Understanding these profiles helps identify which material combinations tend to produce stronger or weaker concretes.
		*Cluster 1: ~33 MPa, high slag + fly ash
		*Cluster 2: ~54 MPa, highest cement + superplasticizer
		*Cluster 3: ~31 MPa, balanced mixes, lowest strength
		*Cluster 4: ~44 MPa, very old mixes (~260 days)";
proc means data=clusters mean median std maxdec=2;
    class cluster;
    var compressivestrength age cementwater slagwater flyashwater superplasticizerwater coarsewater finewater;
run;
ods text="2.3 ANOVA: Strength Differences Across Clusters";
ods text="ANOVA was used to evaluate strength differences between clusters. The strong significance supports clear distinctions in mix behavior and performance.
		*ANOVA p-value: <0.0001
		*Strongest: Cluster 2 (~54 MPa)
		*Weakest: Cluster 3 (~31 MPa)
		*Strength difference across clusters: ~23 MPa";
proc glm data=clusters;
    class cluster;
    model compressivestrength = cluster;
    means cluster / tukey hovtest=levene;
run;
quit;
ods text=" Section 3 — Regression Model for Strength (Age =100 Days)";
ods text="3.1 Objective";
ods text="A regression model was built for mature concrete (=100 days) to isolate the effects of mix components on long-term strength, independent of early hydration.
		*Sample size: ~114 mature samples
		*Goal: predict strength purely from composition
		*Removes early-age noise";
data old100;
    set concreteratios;
    if age >= 100;
run;
ods text="3.2 Regression Results";
ods text="Stepwise regression identified key mix components that significantly influence long-term strength. Cement, slag, and superplasticizer improve strength, while excessive fine aggregate has a slight weakening effect.
		*Predictors selected:
			Cement/water (+14.5 MPa)
			Slag/water (+15 MPa)
			Superplasticizer/water (+260 MPa)
			Fine aggregate/water (–2.6 MPa)
		*Model R²: 0.56
		*Age not included ? strength plateau";
proc reg data=old100;
    model compressivestrength =
        cementwater slagwater flyashwater superplasticizerwater
        coarsewater finewater age
        / selection=stepwise slentry=0.15 slstay=0.15 vif;
    output out=old100_reg p=pred r=resid;
run;
quit;
ods text=" Section 4 — Logistic Model: Predicting =50 MPa Strength (Age 90–100 Days)";
ods text="4.1 Setup";
ods text="A logistic regression model was used to classify whether concrete aged 90–100 days achieves at least 50 MPa, a common structural threshold.
		*Window analyzed: 90–100 days
		*Binary target: 1 = =50 MPa
		*Sample size: ~128 mixes";
data age90100;
    set concreteratios;
    if 90 <= age <= 100;
    strong50 = (compressivestrength >= 50);
run;
ods text="4.2 Logistic Results";
ods text="The model performed very well, with cement, slag, and superplasticizer increasing strength likelihood, and coarse aggregate and fly ash decreasing it.
		*Predictors selected: cement, slag, superplasticizer, fly ash, coarse aggregate
		*Accuracy: ~95%
		*AUC: 0.90–0.93
		*Misclassification: <5%";
proc logistic data=age90100 descending;
    model strong50 =
        cementwater slagwater flyashwater superplasticizerwater
        coarsewater finewater
        / selection=stepwise slentry=0.15 slstay=0.15 outroc=roc90100;
run;
ods text=" Section 5 — Discriminant Analysis for Age Group Classification";
ods text="5.1 Purpose";
ods text="Linear Discriminant Analysis (LDA) was applied to classify samples into age groups based on mix composition and strength patterns, highlighting how well curing stage can be inferred from material characteristics.
		*Groups classified: 5
		*Predictors used: 7 ratios + strength
		*Method: LDA with cross-validation";
proc discrim data=concreteratios method=normal pool=test crossvalidate;
    class agegroup;
    var cementwater slagwater flyashwater superplasticizerwater coarsewater finewater compressivestrength;
run;
ods text="5.2 LDA Results";
ods text="The model shows moderate accuracy overall. Early-age and long-cured concrete are easiest to classify, while middle-age groups overlap due to similar strength ranges.
		*Overall accuracy: 65–70%
		*Group 1: ~80%
		*Group 2: ~78%
		*Groups 3 & 4: ~30–40%
		*Group 5: ~42%";
proc discrim data=concreteratios
             method=normal pool=test
             crossvalidate
             out=lda_cv;
    class agegroup;
    var cementwater slagwater flyashwater superplasticizerwater coarsewater finewater compressivestrength;
run;
ods rtf close;
