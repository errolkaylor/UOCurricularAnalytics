This shiny application highlights two curricular networks at UO related to Computer Science, based on work from (Heileman et al. (2018))[https://doi.org/10.48550%2FarXiv.1811.096] and the r (CurricularAnalytics)[https://cran.r-project.org/web/packages/CurricularAnalytics/] package.

1. A complete course network that incorporates multiple departments (Computer Science, Math, and Physics), allowing to see how course prerequsites are linked across departments and programs.
2. Degree plan generator for UO Computer Science Majors at UO, and the accompanying analytics for maximal and minimal degree plans.

Basics for interpreting the graphs:
1. Each node is an individual course -- arrows denote that one course is a necessary prerequisite before enrolling in another.
2. Each class has several associated curricular complexity metrics:
    * Delay Factor -- The longest course sequence the course is a part of.
    * Blocking Factor -- The number of courses our initial course is. 
    * Centrality -- The number of possible sequences that include the course as both a pre-requisite and having a pre-requisite itself.
    * Structural Complexity -- The combination of Delay Factor and Blocking factor.
3. Minimal and Maximal degree paths highlight the different paths that students might take, and which courses appear in only one path.
    * Code for generating and analyzing potential degree pathways is included in comments in the app.r file. 
